import 'dart:io';

import 'package:flutter_textgrid/flutter_textgrid.dart';
import 'package:flutter_textgrid/src/io/text_grid_serializer.dart';
import 'package:test/test.dart';

void main() {
  group(
    "TextGrid Long Type",
    () {
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
        'Long Version: Performance Test',
        () {
          const xmax = 10000;
          final List<Annotation> intervals = List.empty(growable: true);

          for (int i = 0; i < xmax; ++i) {
            intervals.add(
              IntervalAnnotation(
                start: i.toTime(),
                end: (i + 1).toTime(),
                text: i.toString(),
              ),
            );
          }

          final tier = IntervalTier(
            name: "lots",
            start: Time.zero,
            end: xmax.toTime(),
            annotations: intervals,
          );
          final tg = TextGrid(
            startTime: Time.zero,
            endTime: Time.int(xmax),
          );
          tg.addTier(tier);

          expect(tg, isNot(null));
        },
      );
    },
  );

  group(
    "Test Tier",
    () {
      test(
        "Adding",
        () {
          final t = IntervalTier(name: "");

          final ao1 = IntervalAnnotation(
            start: Time.zero,
            end: const Time(0.5),
            text: 'ao1',
          );
          t.addAnnotation(ao1);

          expect(t.annotations.length == 1, true);
          expect(t.start == 0.0, true);
          expect(t.end == 0.5, true);

          // Append to IntervalTier leaving empty space (0.1)
          final ao2 = IntervalAnnotation(
            start: const Time(0.6),
            end: const Time(0.75),
            text: 'ao2',
          );
          t.addAnnotation(ao2);
          expect(t.annotations.length == 2, true);
          expect(t.start == 0.0, true);
          expect(t.end == 0.75, true);

          final ao3 = IntervalAnnotation(
            start: const Time(0.81),
            end: const Time(0.9),
            text: 'ao3',
          );
          t.addAnnotation(ao3);
          expect(t.annotations.length == 3, true);
          expect(t.start == 0.0, true);
          expect(t.end == 0.9, true);

          // Insert between existing annotations
          // leaving gaps on both sides
          final ao4 = IntervalAnnotation(
            start: const Time(0.75),
            end: const Time(0.77),
            text: 'ao4',
          );
          final r = t.addAnnotation(ao4);
          expect(t.annotations.length == 4, true);
          expect(t.start == 0.0, true);
          expect(t.end == 0.9, true);

          // Meeting preeceding annotation
          final ao5 = IntervalAnnotation(
            start: const Time(0.77),
            end: const Time(0.79),
            text: 'ao5',
          );
          t.addAnnotation(ao5);
          expect(t.annotations.length == 5, true);
          expect(t.start == 0.0, true);
          expect(t.end == 0.9, true);

          // Meeting preeceding and succeeding annotation
          final ao6 = IntervalAnnotation(
            start: const Time(0.8),
            end: const Time(0.81),
            text: 'ao6',
          );
          t.addAnnotation(ao6);
          expect(t.annotations.length == 6, true);
          expect(t.start == 0.0, true);
          expect(t.end == 0.9, true);

          // insert at a place that is already occupied
          // within ao3

          final ao7 = IntervalAnnotation(
            start: const Time(0.85),
            end: const Time(0.87),
            text: 'ao7',
          );
          var result = t.addAnnotation(ao7);
          expect(result.isError, true);

          // Same boundaries as ao3
          final ao8 = IntervalAnnotation(
            start: const Time(0.81),
            end: const Time(0.9),
            text: 'ao8',
          );
          expect(t.addAnnotation(ao8).isError, true);

          // start time earlier than start time of ao3
          final ao9 = IntervalAnnotation(
            start: const Time(0.81),
            end: const Time(0.89),
            text: 'ao9',
          );
          expect(t.addAnnotation(ao9).isError, true);

          // end time later than end time of ao3
          final ao10 = IntervalAnnotation(
            start: const Time(0.82),
            end: const Time(0.91),
            text: 'ao10',
          );
          expect(t.addAnnotation(ao10).isError, true);

          // start time earlier than start time of ao3 and
          // end time later than end time of ao3
          final ao11 = IntervalAnnotation(
            start: const Time(0.8),
            end: const Time(0.91),
            text: 'ao11',
          );
          expect(t.addAnnotation(ao11).isError, true);
        },
      );
    },
  );

  group(
    "TextGrid Short Type",
    () {},
  );
}
