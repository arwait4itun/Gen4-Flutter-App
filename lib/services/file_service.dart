import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';


class FileService {


  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();


    String _logPath = directory!.path+"/flyer_logs";

    if(File(_logPath).existsSync()){
      return _logPath;
    }
    else{
      Directory directory = await Directory(_logPath).create(recursive: true);
      return directory.path;
    }
  }

  Future<File> get _localFile async {
    //creates new file based on time and returns it's path
    final path = await _localPath;

    DateTime now = DateTime.now();

    String _logDir = "${path}/${DateFormat('dd_MM_yyyy').format(now).toString()}";

    String _logFile = DateFormat('HH_mm_SS').format(now).toString();

    Directory directory = await Directory(_logDir).create(recursive: true);

    return File(directory.path+"/${_logFile}.csv");

  }


  Future<void> writeLog(List<List<String>> logData) async {
    final file = await _localFile;

    try {
      String csv = const ListToCsvConverter().convert(logData);
      // Write the file
      await file.writeAsString(csv);
      print(file.path);
    }
    catch(e){
      print("File Service: $e");
    }


  }
}

void main() {

  List<List<String>> _list = [["hi","bye"],["12","34"]];

  FileService().writeLog(_list);

}