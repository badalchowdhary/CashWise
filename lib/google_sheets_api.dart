import 'package:gsheets/gsheets.dart';

class GoogleSheetsApi {
  //create credentials
  static const _credentials = r'''
  {
  "type": "service_account",
  "project_id": "cashwise",
  "private_key_id": "c38d2ec038ac0ba3d116e975d1e988b0b03fbfbb",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQClpaIkk5hTn59D\nSUBKk3AAZkEPD/ZZWR8VQqICe4ZNFTc4VjIWOj3K6Nik/0rLm5HI1MPUe18XUVg8\nlwT01TsjMRZ77qVEeacbPjUXcqTIs2kBhieJNJFFnj8e7ic5vo5gaSlUu6SAZVdS\nn1FCjTyxl1TibnMlOTim08Oj6N+cvbRzjbmIqdykPNEwPccHPL/pMh77SJMAxOWY\nR4mtVpsQ6gcxLbJOfj3tz+k7++4CjqBCu4Ohdxk6f2RCw1cZX854l/4fiaiLu4SM\nLySvW6dlaWwvQwa9tPKqlh2rTn6No9X6JWAibIJoB/goec+kci5kZizINFhqH25u\n9Yw5+y35AgMBAAECggEAECZRZBqFt+VwnBlIrNyqB0fw4NyQCo7/Uk3QSMitQ9el\nLhdtQ7CC9MT11kRTkP1GXdusigtLLpVOMn4QzCP744b2J7gRIddwfN34RCR3v1+K\nhc0EDsLyxORUSBo09dLHw8uM7Ydr1t7KgDIrNH9bov7blkXpcQAer1knElRydK/7\nwHdsP52ti3SfmWxVk2jC4OArtcI209uTS5qlnR7evA92kxFjgVR8WBjvxupC+a8O\nV0FomReNGS+YMDltborRHDvjMSihUrcQQwllJzG8t1zSqpGCGRFxDOO7Yl1FdWNy\nCQT6mxHo4S//bWEMpYPPE6rcvF8fx02s1NiidXUfPwKBgQDmIApfUkWKECElHW/p\nnjvZTKlHNP6Y5RquZ++w4twRiz6+PXToPPiY1YPESn05gmXQhrMCjGCfXiOs3dRc\nMiAcAhpFm1qR0oEO0ltiUvTVImZSoRq31U8zYYdLrq6TdizZcrOi/CT6p5aZ+UvN\nQ2mfyjRsl4iV1ZHViyLZc6Vu9wKBgQC4RaSy0PfrFVp5FoNNdtpOVg6UL765npBE\nUr3s9AwpcoJ+HjaIXzW6EOThQhsLxBbw77+CpRkc29RmP5Zttn+3TwvloOXt8V1w\nLDqFLU8LwIlWwpOT251p7p5Dv+YZvebVPvwe8rG03KJNuOL3E/Lgt84r1l5Ol8e/\nSsX3GmjejwKBgCGdSoaT+O5q3rySKTfB0lIyfYOWPR5OUPBq5Ds9WBID+f1F8t69\nkT6Z6a5xhwswffjQxDM6GB8PXDyzBoMVG1WcBQRn5fno+ssUdR7OqU68wJ+PQtzZ\nfsEtnNq0QHHv0CtPMug61pf6hOgm3yizkSkzGydFl0DzumKr+UI0P1UPAoGACXpz\nlUsQZYQsqivRRyvE4OCmUVL/YXbZftousMCA26TrN2eAcJVNIyv5SejnkTxd3bjH\nRgYN+6EHFNdSeoQ3n4suVnpnOUz//GQaAn2pIjaeGdtaUfGq8Cb49w0o3cwZ0oAx\n4bmkEGSE6LCI5CKfjJWHwlN9eFdwS9OhySsPl9sCgYEAtU4RNWRv0WxXzRvWOEu/\nKKHqKOK+iHLEZyAP+TsPz1lIR7nbGo4EjMB5cPB5VFSNLdkA4QqNv8S2Xp86BkSa\n5Yb/E3p0cY3xSE/LSggwHAjaypRpdK7lpjW1hNc00OOFIVMF/wwBqBV8L3FyXVmv\nlWmv2kisvPvTISPn8bkwfWY=\n-----END PRIVATE KEY-----\n",
  "client_email": "cashwise@cashwise.iam.gserviceaccount.com",
  "client_id": "108939144342583240216",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/cashwise%40cashwise.iam.gserviceaccount.com"
  }
  ''';

  //Connect spreadsheet
  static final _spreadsheetId = '17Lv9pXtbIAycQZhwFwQArK-_d5ujuoQnUVCdTvNCs0k';
  static final _gsheets = GSheets(_credentials);
  static Worksheet? _worksheet;

  // Variables
  static int numberOfTransactions = 0;
  static List<List<dynamic>> currentTransactions = [];
  static bool loading = true;

  //Initialize Spreadsheet
  Future init() async {
    final ss = await _gsheets.spreadsheet(_spreadsheetId);
    _worksheet = ss.worksheetByTitle('Worksheet1');
    countRows();
  }

  // count the number of notes
  static Future countRows() async {
    while ((await _worksheet!.values
        .value(column: 1, row: numberOfTransactions + 1)) !=
        '') {
      numberOfTransactions++;
    }
    // now we know how many notes to load, now let's load them!
    loadTransactions();
  }

  // load existing notes from the spreadsheet
  static Future loadTransactions() async {
    if (_worksheet == null) return;

    for (int i = 1; i < numberOfTransactions; i++) {
      final String transactionName =
      await _worksheet!.values.value(column: 1, row: i + 1);
      final String transactionAmount =
      await _worksheet!.values.value(column: 2, row: i + 1);
      final String transactionType =
      await _worksheet!.values.value(column: 3, row: i + 1);

      if (currentTransactions.length < numberOfTransactions) {
        currentTransactions.add([
          transactionName,
          transactionAmount,
          transactionType,
        ]);
      }
    }
    print(currentTransactions);
    // this will stop the circular loading indicator
    loading = false;
  }

  // insert a new transaction
  static Future insert(String name, String amount, bool _isIncome) async {
    if (_worksheet == null) return;
    numberOfTransactions++;
    currentTransactions.add([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
    await _worksheet!.values.appendRow([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
  }

  // CALCULATE THE TOTAL INCOME!
  static double calculateIncome() {
    double totalIncome = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'income') {
        totalIncome += double.parse(currentTransactions[i][1]);
      }
    }
    return totalIncome;
  }

  // CALCULATE THE TOTAL EXPENSE!
  static double calculateExpense() {
    double totalExpense = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'expense') {
        totalExpense += double.parse(currentTransactions[i][1]);
      }
    }
    return totalExpense;
  }
}
