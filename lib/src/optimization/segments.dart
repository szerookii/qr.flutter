import 'dart:convert';

import 'mode.dart';
import 'numeric_data.dart';
import 'alphanumeric_data.dart';
import 'byte_data.dart';
import 'kanji_data.dart';
import 'regex.dart';
import 'utils.dart';
import 'package:dijkstra/dijkstra.dart';

int getStringByteLength(String str) {
  return utf8.encode(str).length;
}

List<Map<String, dynamic>> getSegments(RegExp regex, Mode mode, String str) {
  List<Map<String, dynamic>> segments = [];
  Iterable<RegExpMatch> matches = regex.allMatches(str);

  for (var match in matches) {
    segments.add({
      'data': match.group(0),
      'index': match.start,
      'mode': mode,
      'length': match.group(0)?.length
    });
  }

  return segments;
}

List<Map<String, dynamic>> getSegmentsFromString(String dataStr) {
  List<Map<String, dynamic>> numSegs = getSegments(Regex.NUMERIC, Mode.NUMERIC, dataStr);
  List<Map<String, dynamic>> alphaNumSegs = getSegments(Regex.ALPHANUMERIC, Mode.ALPHANUMERIC, dataStr);
  List<Map<String, dynamic>> byteSegs;
  List<Map<String, dynamic>> kanjiSegs;

  if (Utils.isKanjiModeEnabled()) {
    byteSegs = getSegments(Regex.BYTE, Mode.BYTE, dataStr);
    kanjiSegs = getSegments(Regex.KANJI, Mode.KANJI, dataStr);
  } else {
    byteSegs = getSegments(Regex.BYTE_KANJI, Mode.BYTE, dataStr);
    kanjiSegs = [];
  }

  List<Map<String, dynamic>> segs = numSegs + alphaNumSegs + byteSegs + kanjiSegs;

  segs.sort((s1, s2) => s1['index'] - s2['index']);

  return segs.map((obj) {
    return {
      'data': obj['data'],
      'mode': obj['mode'],
      'length': obj['length']
    };
  }).toList();
}

int getSegmentBitsLength(int length, Mode mode) {
  switch (mode) {
    case Mode.NUMERIC:
      return NumericData.getBitsLength(length);
    case Mode.ALPHANUMERIC:
      return AlphanumericData.getBitsLength(length);
    case Mode.KANJI:
      return KanjiData.getBitsLength(length);
    case Mode.BYTE:
      return ByteData.getBitsLength(length);
    default:
      throw ArgumentError('Invalid mode: $mode');
  }
}

List<Map<String, dynamic>> mergeSegments(List<Map<String, dynamic>> segs) {
  return segs.fold<List<Map<String, dynamic>>>([], (acc, curr) {
    if (acc.isNotEmpty && acc.last['mode'] == curr['mode']) {
      acc.last['data'] += curr['data'];
      return acc;
    }
    acc.add(curr);
    return acc;
  });
}

List<List<Map<String, dynamic>>> buildNodes(List<Map<String, dynamic>> segs) {
  List<List<Map<String, dynamic>>> nodes = [];
  for (var seg in segs) {
    switch (seg['mode']) {
      case Mode.NUMERIC:
        nodes.add([
          seg,
          {'data': seg['data'], 'mode': Mode.ALPHANUMERIC, 'length': seg['length']},
          {'data': seg['data'], 'mode': Mode.BYTE, 'length': seg['length']}
        ]);
        break;
      case Mode.ALPHANUMERIC:
        nodes.add([
          seg,
          {'data': seg['data'], 'mode': Mode.BYTE, 'length': seg['length']}
        ]);
        break;
      case Mode.KANJI:
        nodes.add([
          seg,
          {'data': seg['data'], 'mode': Mode.BYTE, 'length': getStringByteLength(seg['data'])}
        ]);
        break;
      case Mode.BYTE:
        nodes.add([
          {'data': seg['data'], 'mode': Mode.BYTE, 'length': getStringByteLength(seg['data'])}
        ]);
        break;
    }
  }
  return nodes;
}

Map<String, dynamic> buildGraph(List<List<Map<String, dynamic>>> nodes, int version) {
  Map<String, Map<String, int>> graph = {'start': {}};
  Map<String, Map<String, dynamic>> table = {};
  List<String> prevNodeIds = ['start'];

  for (int i = 0; i < nodes.length; i++) {
    List<Map<String, dynamic>> nodeGroup = nodes[i];
    List<String> currentNodeIds = [];

    for (int j = 0; j < nodeGroup.length; j++) {
      Map<String, dynamic> node = nodeGroup[j];
      String key = '$i$j';

      currentNodeIds.add(key);
      table[key] = {'node': node, 'lastCount': 0};
      graph[key] = {};

      for (String prevNodeId in prevNodeIds) {
        if (table[prevNodeId] != null && table[prevNodeId]?['node']['mode'] == node['mode']) {
          graph[prevNodeId]?[key] = getSegmentBitsLength(
              table[prevNodeId]?['lastCount'] + node['length'], node['mode']) -
              getSegmentBitsLength(table[prevNodeId]?['lastCount'], node['mode']);
          table[prevNodeId]?['lastCount'] += node['length'];
        } else {
          if (table[prevNodeId] != null) table[prevNodeId]?['lastCount'] = node['length'];
          graph[prevNodeId]?[key] = getSegmentBitsLength(node['length'], node['mode']) +
              4 + Mode.getCharCountIndicator(node['mode'], version);
        }
      }
    }

    prevNodeIds = currentNodeIds;
  }

  for (String prevNodeId in prevNodeIds) {
    graph[prevNodeId]?['end'] = 0;
  }

  return {'map': graph, 'table': table};
}

dynamic buildSingleSegment(String data, Mode? modesHint) {
  Mode bestMode = Mode.getBestModeForData(data);
  Mode mode = Mode.from(modesHint, bestMode);

  if (mode != Mode.BYTE && mode.bit < bestMode.bit) {
    throw ArgumentError('"$data" cannot be encoded with mode ${Mode.modeToString(mode)}.\n Suggested mode is: ${Mode.modeToString(bestMode)}');
  }

  if (mode == Mode.KANJI && !Utils.isKanjiModeEnabled()) {
    mode = Mode.BYTE;
  }

  switch (mode) {
    case Mode.NUMERIC:
      return NumericData(data);
    case Mode.ALPHANUMERIC:
      return AlphanumericData(data);
    case Mode.KANJI:
      return KanjiData(data);
    case Mode.BYTE:
      return ByteData(data);
    default:
      throw ArgumentError('Invalid mode: $mode');
  }
}

List<dynamic> fromArray(List<dynamic> array) {
  return array.fold<List<dynamic>>([], (acc, seg) {
    if (seg is String) {
      acc.add(buildSingleSegment(seg, null));
    } else if (seg is Map<String, dynamic> && seg.containsKey('data')) {
      acc.add(buildSingleSegment(seg['data'], seg['mode']));
    }
    return acc;
  });
}

List<dynamic> fromString(String data, int version) {
  List<Map<String, dynamic>> segs = getSegmentsFromString(data);
  List<List<Map<String, dynamic>>> nodes = buildNodes(segs);
  Map<String, dynamic> graph = buildGraph(nodes, version);
  List<String> path = List<String>.from(Dijkstra.findPathFromGraph(graph['map'], 'start', 'end') );

  List<Map<String, dynamic>> optimizedSegs = [];
  for (int i = 1; i < path.length - 1; i++) {
    optimizedSegs.add(graph['table'][path[i]]['node']);
  }

  return fromArray(mergeSegments(optimizedSegs));
}

List<dynamic> rawSplit(String data) {
  return fromArray(getSegmentsFromString(data));
}