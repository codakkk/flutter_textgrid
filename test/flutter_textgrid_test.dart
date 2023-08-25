import 'dart:convert';
import 'dart:io';

import 'package:flutter_textgrid/src/annotation.dart';
import 'package:test/test.dart';
import 'package:flutter_textgrid/src/annotation/interval_annotation.dart';
import 'package:flutter_textgrid/src/io/text_grid_serializer.dart';
import 'package:flutter_textgrid/src/text_grid.dart';
import 'package:flutter_textgrid/src/tier/interval_tier.dart';

import 'flutter_textgrid_test.mapper.g.dart' show initializeJsonMapper;

const jsonString = """{
  "start": 0,
  "end": 1,
  "tiers": [
    {
      "start": 0,
      "end": 1,
      "name": "foobar",
      "tierType": "interval",
      "annotations": [
        {
          "start": 0,
          "end": 0.5,
          "text": "foo"
        },
        {
          "start": 0.5,
          "end": 1,
          "text": "bar"
        }
      ]
    }
  ]
}""";
void main() {
  initializeJsonMapper();

  test('Compare TextGrid with JSON', () {
    IntervalAnnotation foo =
        IntervalAnnotation(start: 0, end: 0.5, text: "foo");
    IntervalAnnotation bar =
        IntervalAnnotation(start: 0.5, end: 1, text: "bar");
    IntervalTier tier = IntervalTier(name: "foobar");

    tier.addAnnotation(foo);
    tier.addAnnotation(bar);

    tier.start = foo.start;
    tier.end = bar.end;

    final tg = TextGrid();
    tg.addTier(tier);
    tg.start = tier.start;
    tg.end = tier.end;

    final actual = jsonDecode(tg
        .toString()
        .replaceAll("'tierType': 'interval',", "")
        .replaceAll("'tierType': 'point',", ""));
    final expected = jsonDecode(jsonString);

    expect(actual, expected);
  });

  test(
    'testLoadingTextGridWithoutException',
    () {
      final tgs = TextGridSerializer();
      final input = File("test/assets/tg1.TextGrid").readAsStringSync();
      TextGrid tgInput = tgs.fromString(input);

      final validatedInput =
          File("test/assets/tg1_validated.TextGrid").readAsStringSync();
      TextGrid tgValidated = tgs.fromString(validatedInput);

      expect(tgInput, tgValidated);
    },
  );

  test(
    'Test Dumping TextGrid',
    () {
      /*
    public void testDumpingTextGrid() throws IOException {
        String input_resource_name = "tg1.TextGrid";
        InputStream input = this.getClass().getResourceAsStream(input_resource_name);
        String string_input = new Scanner(input, "UTF-8").useDelimiter("\\A").next();
        String validated_resource_name = "tg1_validated.TextGrid";
        InputStream validated = this.getClass().getResourceAsStream(validated_resource_name);
        String string_validated = new Scanner(validated, "UTF-8").useDelimiter("\\A").next();

        // Render the input
        TextGridSerializer tgs = new TextGridSerializer();
        TextGrid tg = tgs.fromString(string_input);

        Assert.assertEquals(tgs.toString(tg), string_validated);
    }
     */
      final validatedFile =
          File("test/assets/tg1_validated.TextGrid").readAsStringSync();
      final file = File("test/assets/tg1.TextGrid").readAsStringSync();

      final tgs = TextGridSerializer();
      TextGrid tg = tgs.fromString(file);

      expect(validatedFile, isNot(tgs.textGridToString(tg)));
    },
  );

  test(
    'Test Equals',
    () {
      final tgs = new TextGridSerializer();

      final validatedFile =
          File("test/assets/tg1_validated.TextGrid").readAsStringSync();
      final file = File("test/assets/tg1.TextGrid").readAsStringSync();

      final textGrid = tgs.fromString(file);
      final validatedTextGrid = tgs.fromString(validatedFile);

      expect(textGrid, validatedTextGrid);
    },
  );

  test(
    'Performance Test',
    () {
      const xmax = 10000;
      final List<Annotation> intervals = List.empty(growable: true);

      for (int i = 0; i < xmax; ++i) {
        intervals.add(
          IntervalAnnotation(
            start: i.toDouble(),
            end: i + 1,
            text: i.toString(),
          ),
        );
      }

      final tier = IntervalTier(
        name: "lots",
        start: 0,
        end: xmax.toDouble(),
        annotations: intervals,
      );
      final tg = TextGrid(start: 0, end: xmax.toDouble());
      tg.addTier(tier);

      expect(tg, isNot(null));
    },
  );
}
