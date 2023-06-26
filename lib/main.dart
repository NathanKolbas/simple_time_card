import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_time_card/models/times.dart';

void main() {
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Times(),),
        ],
        child: const MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Times _times = Times();
  late DateTime _currentDate;
  String _newIdText = '';

  late final Timer _timer;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _currentDate = DateTime(now.year, now.month, now.day);

    _timer = Timer.periodic(const Duration(seconds: 15), (timer) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final day = context.select<Times, Map<String, Durations>>((v) => v.getDay(_currentDate));
    final dayKeys = day.keys.toList();

    print(dayKeys);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    _currentDate = _currentDate.subtract(const Duration(days: 1));
                  }),
                  icon: const Icon(Icons.keyboard_arrow_left),
                ),
                const SizedBox(width: 12,),
                Column(
                  children: [
                    Text(
                      "${_currentDate.month}/${_currentDate.day}/${_currentDate.year}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    const SizedBox(height: 4,),
                    Text(
                      "Current ID: ${context.select<Times, String?>((v) => v.currentId) ?? 'Nothing selected'}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(width: 12,),
                IconButton(
                  onPressed: () => setState(() {
                    _currentDate = _currentDate.add(const Duration(days: 1));
                  }),
                  icon: const Icon(Icons.keyboard_arrow_right),
                ),
              ],
            ),
            const SizedBox(height: 18,),
            ListView.builder(
              itemCount: dayKeys.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return EntryItem(currentDate: _currentDate, id: dayKeys[index]);
              },
            ),
            const SizedBox(height: 6,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _textEditingController,
                    onChanged: (value) {
                      _newIdText = value;
                    },
                    decoration: const InputDecoration(
                      hintText: 'ID/name/etc.',
                      contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(2.0)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8,),
                IconButton(
                  onPressed: () {
                    final durationMap = _times.getDay(_currentDate);
                    // Add if it doesn't contain
                    if (!durationMap.containsKey(_newIdText)) {
                      durationMap[_newIdText] = Durations();
                      _textEditingController.clear();
                    }
                    final itemDurations = durationMap[_newIdText];
                    _times.setState();
                    setState(() {});
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class EntryItem extends StatelessWidget {
  const EntryItem({super.key, required this.currentDate, required this.id});

  final DateTime currentDate;
  final String id;

  @override
  Widget build(BuildContext context) {
    final times = Provider.of<Times>(context);
    final durations = times.days[currentDate]![id]!;

    Duration adjustedDuration = durations.duration;
    if (id == times.currentId) {
      adjustedDuration += DateTime.now().difference(durations.times.last.dateTime);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SelectableText(
                id,
                style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 24),
              ),
              const SizedBox(width: 16,),
              SelectableText(
                "${adjustedDuration.inHours}.${(adjustedDuration.inMinutes / 60).toStringAsFixed(2).substring(2)} hrs",
                style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 24),
              ),
              const SizedBox(width: 16,),
              ElevatedButton(
                onPressed: () {
                  final now = DateTime.now();
                  if (times.currentId == id) {
                    times.currentId = null;
                    durations.duration += now.difference(durations.times.last.dateTime);
                    durations.times.add(Punch(PunchType.punchOut, now));
                  } else {
                    if (times.currentId != null) {
                      final otherDurations = times.days[currentDate]![times.currentId]!;
                      otherDurations.duration += now.difference(otherDurations.times.last.dateTime);
                      otherDurations.times.add(Punch(PunchType.punchOut, now));
                    }

                    times.currentId = id;

                    durations.times.add(Punch(PunchType.punchIn, now));
                  }
                  times.setState();
                },
                child: Text(times.currentId == id ? 'Stop' : 'Start'),
              ),
            ],
          ),
          SelectableText(
            durations.times.fold('', (previousValue, element) => previousValue +=
            "${previousValue.isNotEmpty ? ', ' : ''}${element.punchType == PunchType.punchIn ? 'In' : 'Out'}: "
                "${element.dateTime.hour > 12 ? element.dateTime.hour - 12 : element.dateTime.hour == 0 ? 12 : element.dateTime.hour}:${element.dateTime.minute.toString().padLeft(2, '0')} "
                "${element.dateTime.hour >= 12 ? 'PM' : 'AM'}"),
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
