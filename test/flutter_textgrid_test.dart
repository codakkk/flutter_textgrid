import 'dart:io';

import 'package:flutter_textgrid/flutter_textgrid.dart';
import 'package:flutter_textgrid/src/io/text_grid_io_exception.dart';
import 'package:flutter_textgrid/src/io/text_grid_serializer.dart';
import 'package:test/test.dart';

void expectTrue(dynamic actual) {
  expect(actual, true);
}

void expectFalse(dynamic actual) {
  expect(actual, false);
}

void main() {
  group(
    "Time",
    () {
      late Time t1, t2, t3, t4, t5;
      setUp(() {
        t1 = Time(1.0);
        t2 = Time(1.1);
        t3 = Time(1.01);
        t4 = Time(1.001);
        t5 = Time(1.00001);
      });

      test(
        "Equals",
        () {
          expect(t1 == t1, isTrue);
          expect(t1 == t2, isFalse);
          expect(t1 == t3, isFalse);
          expect(t1 == t4, isFalse);
          expect(t1 == t5, isTrue);
        },
      );

      test(
        "Not Equals",
        () {
          expect(t1 != t1, isFalse);
          expect(t1 != t2, isTrue);
          expect(t1 != t3, isTrue);
          expect(t1 != t4, isTrue);
          expect(t1 != t5, isFalse);
        },
      );

      test(
        "Less",
        () {
          expect(t1 < t1, isFalse);
          expect(t1 < t2, isTrue);
          expect(t1 < t3, isTrue);
          expect(t1 < t4, isTrue);
          expect(t1 < t5, isFalse);
        },
      );

      test(
        "Greater",
        () {
          expect(t1 > t1, isFalse);
          expect(t1 > t2, isFalse);
          expect(t1 > t3, isFalse);
          expect(t1 > t4, isFalse);
          expect(t1 > t5, isFalse);
          expect(t2 > t1, isTrue);
        },
      );

      test(
        "Greater Equals",
        () {
          expect(t1 >= t1, isTrue);
          expect(t1 >= t2, isFalse);
          expect(t1 >= t3, isFalse);
          expect(t1 >= t4, isFalse);
          expect(t1 >= t5, isTrue);
          expect(t2 >= t1, isTrue);
        },
      );

      test(
        "Less Equals",
        () {
          expect(t1 <= t1, isTrue);
          expect(t1 <= t2, isTrue);
          expect(t1 <= t3, isTrue);
          expect(t1 <= t4, isTrue);
          expect(t1 <= t5, isTrue);
          expect(t2 <= t1, isFalse);
        },
      );
    },
  );

  group(
    "Tier",
    () {
      test(
        "Adding",
        () {
          final t = IntervalTier(name: "");

          final ao1 = IntervalAnnotation(
            startTime: Time.zero,
            endTime: const Time(0.5),
            text: 'ao1',
          );
          t.addAnnotation(ao1);

          expect(t.annotations.length == 1, true);
          expect(t.startTime == Time(0.0), true);
          expect(t.endTime == Time(0.5), true);

          // Append to IntervalTier leaving empty space (0.1)
          final ao2 = IntervalAnnotation(
            startTime: const Time(0.6),
            endTime: const Time(0.75),
            text: 'ao2',
          );
          t.addAnnotation(ao2);
          expect(t.annotations.length == 2, true);
          expect(t.startTime == Time(0.0), true);
          expect(t.endTime == Time(0.75), true);

          final ao3 = IntervalAnnotation(
            startTime: const Time(0.81),
            endTime: const Time(0.9),
            text: 'ao3',
          );
          t.addAnnotation(ao3);
          expect(t.annotations.length == 3, true);
          expect(t.startTime == const Time(0.0), true);
          expect(t.endTime == const Time(0.9), true);

          // Insert between existing annotations
          // leaving gaps on both sides
          final ao4 = IntervalAnnotation(
            startTime: const Time(0.75),
            endTime: const Time(0.77),
            text: 'ao4',
          );
          t.addAnnotation(ao4);
          expect(t.annotations.length == 4, true);
          expect(t.startTime == const Time(0.0), true);
          expect(t.endTime == const Time(0.9), true);

          // Meeting preeceding annotation
          final ao5 = IntervalAnnotation(
            startTime: const Time(0.77),
            endTime: const Time(0.79),
            text: 'ao5',
          );
          t.addAnnotation(ao5);
          expect(t.annotations.length == 5, true);
          expect(t.startTime == const Time(0.0), true);
          expect(t.endTime == const Time(0.9), true);

          // Meeting preeceding and succeeding annotation
          final ao6 = IntervalAnnotation(
            startTime: const Time(0.8),
            endTime: const Time(0.81),
            text: 'ao6',
          );
          t.addAnnotation(ao6);
          expect(t.annotations.length == 6, true);
          expect(t.startTime == const Time(0.0), true);
          expect(t.endTime == const Time(0.9), true);

          // insert at a place that is already occupied
          // within ao3

          final ao7 = IntervalAnnotation(
            startTime: const Time(0.85),
            endTime: const Time(0.87),
            text: 'ao7',
          );
          var result = t.addAnnotation(ao7);
          expect(result.isError, true);

          // Same boundaries as ao3
          final ao8 = IntervalAnnotation(
            startTime: const Time(0.81),
            endTime: const Time(0.9),
            text: 'ao8',
          );
          expect(t.addAnnotation(ao8).isError, true);

          // start time earlier than start time of ao3
          final ao9 = IntervalAnnotation(
            startTime: const Time(0.81),
            endTime: const Time(0.89),
            text: 'ao9',
          );
          expect(t.addAnnotation(ao9).isError, true);

          // end time later than end time of ao3
          final ao10 = IntervalAnnotation(
            startTime: const Time(0.82),
            endTime: const Time(0.91),
            text: 'ao10',
          );
          expect(t.addAnnotation(ao10).isError, true);

          // start time earlier than start time of ao3 and
          // end time later than end time of ao3
          final ao11 = IntervalAnnotation(
            startTime: const Time(0.8),
            endTime: const Time(0.91),
            text: 'ao11',
          );
          expect(t.addAnnotation(ao11).isError, true);

          // Check that no annotation has been added
          expect(t.annotations.length == 6, true);
          expect(t.startTime == Time.zero, true);
          expect(t.endTime == const Time(0.9), true);
        },
      );
      test(
        "Start End Times",
        () {
          final tier = IntervalTier(
            name: "",
            startTime: const Time(1),
            endTime: const Time(2),
          );

          // Check whether specified start/end times are used
          expect(tier.startTime == const Time(1), isTrue);
          expect(tier.endTime == const Time(2), isTrue);

          // Check whether adding an annotation within specified
          // start and end times leaves them unchanged
          tier.addAnnotation(
            IntervalAnnotation(
              startTime: const Time(1.1),
              endTime: const Time(1.9),
              text: 'text',
            ),
          );

          expect(tier.startTime == const Time(1), isTrue);
          expect(tier.endTime == const Time(2), isTrue);

          // Expand end time by adding an annotation that ends later
          tier.addAnnotation(
            IntervalAnnotation(
              startTime: const Time(2),
              endTime: const Time(3),
              text: 'text',
            ),
          );
          expect(tier.startTime == const Time(1), isTrue);
          expect(tier.endTime == const Time(3), isTrue);

          // Expand start time by adding an annotation that starts ealier
          tier.addAnnotation(
            IntervalAnnotation(
              startTime: Time.zero,
              endTime: const Time(1),
              text: 'text',
            ),
          );
          expect(tier.startTime == const Time(0), isTrue);
          expect(tier.endTime == const Time(3), isTrue);
        },
      );
    },
  );

  group(
    "Annotations",
    () {
      group(
        "Interval",
        () {
          test(
            "Change Time",
            () {
              final ict = IntervalAnnotation(
                startTime: Time.zero,
                endTime: const Time(1.0),
                text: "",
              );

              // Changing start and end times has an effect
              ict.startTime = Time(0.5);
              expect(ict.startTime == Time(0.5), isTrue);
              ict.endTime = Time(1.5);
              expect(ict.endTime == Time(1.5), isTrue);

              // Correct order of start and end times is checked
              expect(
                () => IntervalAnnotation(
                    startTime: const Time(1.0), endTime: Time.zero, text: ""),
                throwsA(isA<AssertionError>()),
              );

              expect(() => ict.startTime = Time(2.0), throwsArgumentError);
              expect(() => ict.endTime = Time.zero, throwsArgumentError);
            },
          );

          test(
            "Change Text",
            () {
              final ict = IntervalAnnotation(
                  startTime: Time.zero, endTime: const Time(1.0), text: "text");

              expect(ict.text == "text", isTrue);
              ict.text = "text changed";
              expect(ict.text == "text changed", isTrue);
            },
          );

          test(
            "Duration",
            () {
              final id1 = IntervalAnnotation(
                startTime: Time.zero,
                endTime: const Time(1.0),
                text: "",
              );
              expect(id1.duration == const Time(1.0), isTrue);

              final id2 = IntervalAnnotation(
                startTime: const Time(1.0),
                endTime: const Time(1.0),
                text: "",
              );
              expect(id2.duration == Time.zero, isTrue);
            },
          );

          test(
            "Equality",
            () {
              final ie1 = IntervalAnnotation(
                startTime: Time.zero,
                endTime: const Time(1),
                text: 'text',
              );

              final ie2 = IntervalAnnotation(
                startTime: Time.zero,
                endTime: const Time(1),
                text: 'text',
              );
              expect(ie1 == ie2, isTrue);

              final ie3 = IntervalAnnotation(
                startTime: const Time(1),
                endTime: const Time(1),
                text: 'text',
              );
              expect(ie1 == ie3, isFalse);

              final ie4 = IntervalAnnotation(
                startTime: Time.zero,
                endTime: const Time(2),
                text: 'text',
              );
              expect(ie1 == ie4, isFalse);

              final ie5 = IntervalAnnotation(
                startTime: Time.zero,
                endTime: const Time(1),
                text: 'text changed',
              );
              expect(ie1 == ie5, isFalse);
            },
          );

          test(
            "Clone",
            () {
              final ir = IntervalAnnotation(
                startTime: Time.zero,
                endTime: const Time(1),
                text: "text",
              );
              final c = ir.clone();

              expect(ir == c, isTrue);
            },
          );
        },
      );
      group(
        "Point",
        () {
          test(
            "Change Time",
            () {
              final p = PointAnnotation(time: Time.zero, text: "");
              p.time = Time(0.5);

              expect(p.time == const Time(0.5), isTrue);
              expect(p.startTime == const Time(0.5), isTrue);
              expect(p.endTime == const Time(0.5), isTrue);

              p.startTime = Time(1.0);
              expect(p.time == const Time(1), isTrue);
              expect(p.startTime == const Time(1), isTrue);
              expect(p.endTime == const Time(1), isTrue);

              p.endTime = Time(0.5);
              expect(p.time == const Time(0.5), isTrue);
              expect(p.startTime == const Time(0.5), isTrue);
              expect(p.endTime == const Time(0.5), isTrue);
            },
          );

          test(
            "Change Text",
            () {
              final point = PointAnnotation(time: Time.zero, text: "Text");
              expect(point.text == "Text", isTrue);

              point.text = "text changed";
              expect(point.text == "text changed", isTrue);
            },
          );

          test(
            "Clone",
            () {
              final point = PointAnnotation(time: Time.zero, text: "Text");
              final c = point.clone();

              expect(point == c, isTrue);
            },
          );
        },
      );
    },
  );

  group(
    "TextGrid: Long",
    () {
      late TextGridSerializer tgs;
      late String tg1String;
      late String tg1ValidatedString;

      setUp(() {
        tgs = TextGridSerializer();
        tg1String = File("test/assets/tg1.TextGrid").readAsStringSync();
        tg1ValidatedString =
            File("test/assets/tg1_validated.TextGrid").readAsStringSync();
      });

      group(
        'Loading',
        () {
          test(
            'From String',
            () {
              TextGrid tgInput = tgs.fromString(tg1String);
              TextGrid tgValidated = tgs.fromString(tg1ValidatedString);

              expect(tgInput, tgValidated);
            },
          );

          test(
            'From File',
            () async {
              final result = tgs.fromFile(File('test/assets/tg1.TextGrid'));
              await expectLater(
                result,
                completion(
                  isNot(
                    throwsA(
                      isA<TextGridIOException>(),
                    ),
                  ),
                ),
              );
            },
          );

          test(
            'From Path',
            () async {
              final result = tgs.fromPath('test/assets/tg1.TextGrid');
              await expectLater(
                result,
                completion(
                  isNot(
                    throwsA(
                      isA<TextGridIOException>(),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );

      test(
        'Dumping',
        () {
          TextGrid tg = tgs.fromString(tg1String);
          expect(tg1ValidatedString, isNot(tgs.textGridToString(tg)));
        },
      );

      test(
        'Equals',
        () {
          final textGrid = tgs.fromString(tg1String);
          final validatedTextGrid = tgs.fromString(tg1ValidatedString);

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
                startTime: i.toTime(),
                endTime: (i + 1).toTime(),
                text: i.toString(),
              ),
            );
          }

          final tier = IntervalTier(
            name: "lots",
            startTime: Time.zero,
            endTime: xmax.toTime(),
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
    "TextGrid: Short",
    () {
      late TextGridSerializer tgs;
      late String shortTgString;
      setUp(() {
        tgs = TextGridSerializer();
        shortTgString =
            File("test/assets/short_tg.TextGrid").readAsStringSync();
      });

      group(
        'Loading',
        () {
          test(
            "From String",
            () {
              expect(
                () => tgs.fromString(shortTgString),
                isNot(
                  throwsA(
                    isA<TextGridIOException>(),
                  ),
                ),
              );
            },
          );

          test(
            'From File',
            () async {
              final result =
                  tgs.fromFile(File('test/assets/short_tg.TextGrid'));
              await expectLater(
                result,
                completion(
                  isNot(
                    throwsA(
                      isA<TextGridIOException>(),
                    ),
                  ),
                ),
              );
            },
          );

          test(
            'From Path',
            () async {
              final result = tgs.fromPath('test/assets/short_tg.TextGrid');
              await expectLater(
                result,
                completion(
                  isNot(
                    throwsA(
                      isA<TextGridIOException>(),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );

      test(
        'Equals',
        () {
          final textGrid = tgs.fromString(shortTgString);
          final validatedTextGrid = tgs.fromString(shortTgString);

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
                startTime: i.toTime(),
                endTime: (i + 1).toTime(),
                text: i.toString(),
              ),
            );
          }

          final tier = IntervalTier(
            name: "lots",
            startTime: Time.zero,
            endTime: xmax.toTime(),
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
}
