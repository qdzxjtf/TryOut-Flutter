import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_services.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  int _currentId = 1;
  int _totalQuestion = 0;
  Map<String, dynamic>? _question;
  List<dynamic> _options = [];
  dynamic _selectedOptionId;
  bool _isLoading = true;

  Map<int, dynamic> _jawabanUser = {};
  List<Map<String, dynamic>> _dataSoal = [];

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    await _fetchTotalQuestions();
    await _loadQuestion();
  }

  Future<void> _fetchTotalQuestions() async {
    try {
      final resp = await ApiService.get('/api/v1/tryout/question', useToken: true);
      final data = json.decode(resp.body);
      final List<dynamic> list = data['data'] ?? [];

      setState(() {
        _totalQuestion = list.length;
      });
    } catch (e) {
      print('Gagal mengambil jumlah soal: $e');
    }
  }

  Future<void> _loadQuestion() async {
    setState(() {
      _isLoading = true;
      _question = {};
      _options = [];
      _selectedOptionId = null;
    });

    try {
      final questionResp = await ApiService.get('/api/v1/tryout/question/$_currentId', useToken: true);
      final optionResp = await ApiService.get('/api/v1/tryout/question-option?question_id=$_currentId', useToken: true);

      final questionData = json.decode(questionResp.body);
      final optionData = json.decode(optionResp.body);

      final soal = questionData['data'];
      final allOptions = optionData['data'] ?? [];

      final filteredOptions = allOptions.where((opt) => opt['tryout_question_id'] == _currentId).toList();

      _dataSoal.removeWhere((item) => item['id'] == _currentId);
      _dataSoal.add({
        'id': _currentId,
        'soal': soal,
        'options': filteredOptions,
      });

      setState(() {
        _question = soal;
        _options = filteredOptions;
        _selectedOptionId = _jawabanUser[_currentId];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat soal: $e')),
      );
    }
  }

  void _nextQuestion() {
    if (_currentId < _totalQuestion) {
      setState(() => _currentId++);
      _loadQuestion();
    }
  }

  void _previousQuestion() {
    if (_currentId > 1) {
      setState(() => _currentId--);
      _loadQuestion();
    }
  }

  void _selectOption(dynamic optionId) {
    setState(() {
      _selectedOptionId = optionId;
      _jawabanUser[_currentId] = optionId;
    });
  }

  void _selesaikanTryout() {
    int benar = 0;
    int salah = 0;
    int kosong = 0;

    for (var item in _dataSoal) {
      final id = item['id'];
      final jawabanUser = _jawabanUser[id];

      if (jawabanUser == null) {
        kosong++;
        continue;
      }

      final opsi = item['options'] as List<dynamic>;
      final jawabanBenar = opsi.firstWhere(
        (opt) => opt['iscorrect'] == 1,
        orElse: () => null,
      );

      if (jawabanBenar != null && jawabanUser == jawabanBenar['id']) {
        benar++;
      } else {
        salah++;
      }
    }

    final total = _dataSoal.length;
    final skor = (benar / total * 100).toStringAsFixed(2);

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/result',
      (route) => false,
      arguments: {
        'total': total,
        'benar': benar,
        'salah': salah,
        'kosong': kosong,
        'skor': skor,
      },
    );
  }

  void _showReportDialog() {
    final TextEditingController reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lapor Soal'),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Tuliskan alasan laporan',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final alasan = reasonCtrl.text.trim();

              if (alasan.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alasan tidak boleh kosong')),
                );
                return;
              }

              try {
                await ApiService.post('/api/v1/tryout/lapor-soal/create', {
                  'tryout_question_id': _currentId.toString(),
                  'laporan': alasan,
                }, useToken: true);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Laporan berhasil dikirim')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal mengirim laporan: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.orange,
            ),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _totalQuestion == 0) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final questionText =
        _question != null && _question!.isNotEmpty ? _question!['soal'] ?? 'Soal tidak ditemukan' : null;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blueAccent,
          title: const Text(
            'TryOut',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Soal $_currentId dari $_totalQuestion',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              if (questionText == null)
                const Text(
                  'Soal tidak ditemukan atau sudah habis.',
                  style: TextStyle(color: Colors.red),
                )
              else
                Text(
                  'Soal $_currentId\n\n$questionText',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),
              ..._options.map((opt) {
                final optionId = opt['id'];
                final inisial = opt['inisial'] ?? '-';
                final jawaban = opt['jawaban'] ?? 'Opsi tidak tersedia';
                final optionText = '$inisial. $jawaban';

                return RadioListTile(
                  title: Text(
                    optionText,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  value: optionId,
                  groupValue: _selectedOptionId,
                  onChanged: (val) => _selectOption(val),
                );
              }).toList(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentId > 1)
                    ElevatedButton(
                      onPressed: _previousQuestion,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text('Sebelumnya'),
                    ),
                  if (questionText != null && _currentId < _totalQuestion)
                    ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text('Berikutnya'),
                    ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _showReportDialog,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepOrange,
                    ),
                    child: const Text('Lapor Soal'),
                  ),
                  if (_currentId == _totalQuestion)
                    ElevatedButton(
                      onPressed: _selesaikanTryout,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Selesai Tryout'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
