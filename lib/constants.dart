import 'package:flutter_dotenv/flutter_dotenv.dart';

final riftServerBaseUrl =
    dotenv.env['RIFT_SERVER_BASE_URL'] ?? '127.0.0.1:8000';
