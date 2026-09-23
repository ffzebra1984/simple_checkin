import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '简易打卡',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CheckInPage(),
    );
  }
}

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  List<String> weekRecords = [];

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  // 获取本周所有日期字符串（yyyy-MM-dd）
  List<String> getThisWeekDateList() {
    final now = DateTime.now();
    // 本周周一
    final monday = now.subtract(Duration(days: now.weekday - 1));
    List<String> dates = [];
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      dates.add(DateFormat("yyyy-MM-dd").format(day));
    }
    return dates;
  }

  Future<void> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      weekRecords = prefs.getStringList("checkin_list") ?? [];
    });
  }

  Future<void> doCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = DateFormat("yyyy-MM-dd").format(DateTime.now());
    List<String> list = prefs.getStringList("checkin_list") ?? [];
    if (!list.contains(todayStr)) {
      list.add(todayStr);
      await prefs.setStringList("checkin_list", list);
    }
    await loadRecords();
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("打卡成功！")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = getThisWeekDateList();
    return Scaffold(
      appBar: AppBar(title: const Text("一周打卡记录")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 7,
                itemBuilder: (ctx, idx) {
                  String date = weekDays[idx];
                  bool checked = weekRecords.contains(date);
                  return ListTile(
                    title: Text(date),
                    trailing: checked
                        ? const Icon(Icons.check, color: Colors.green)
                        : const Icon(Icons.close, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: doCheckIn,
                child: const Text("今日打卡", style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
