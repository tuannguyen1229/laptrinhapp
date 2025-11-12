import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../../shared/models/borrow_card.dart';
import 'package:intl/intl.dart';

/// Core service để gửi email qua SMTP
/// Hỗ trợ Gmail, SendGrid, Mailgun và custom SMTP
class EmailService {
  final SmtpServer _smtpServer;
  final String _fromEmail;
  final String _fromName;
  final String _libraryPhone;

  // Hardcoded credentials cho tự động gửi email
  static const String _defaultEmail = 'thanhtungnguyen29122014@gmail.com';
  static const String _defaultPassword = 'njye xriu awiy grhy';

  EmailService({
    required SmtpServer smtpServer,
    required String fromEmail,
    String fromName = 'Thư viện PTIT',
    String libraryPhone = '0123456789',
  })  : _smtpServer = smtpServer,
        _fromEmail = fromEmail,
        _fromName = fromName,
        _libraryPhone = libraryPhone;

  /// Factory constructor mặc định với credentials cố định
  factory EmailService.defaultConfig() {
    return EmailService(
      smtpServer: gmail(_defaultEmail, _defaultPassword),
      fromEmail: _defaultEmail,
      fromName: 'Thư viện PTIT',
      libraryPhone: '0869064126',
    );
  }

  /// Factory constructor cho Gmail SMTP
  factory EmailService.gmail({
    required String email,
    required String appPassword,
    String fromName = 'Thư viện PTIT',
    String libraryPhone = '0869064126',
  }) {
    return EmailService(
      smtpServer: gmail(email, appPassword),
      fromEmail: email,
      fromName: fromName,
      libraryPhone: libraryPhone,
    );
  }

  /// Factory constructor cho SendGrid
  factory EmailService.sendGrid({
    required String apiKey,
    required String fromEmail,
    String fromName = 'Thư viện PTIT',
    String libraryPhone = '0869064126',
  }) {
    final smtpServer = SmtpServer(
      'smtp.sendgrid.net',
      port: 587,
      username: 'apikey',
      password: apiKey,
    );
    return EmailService(
      smtpServer: smtpServer,
      fromEmail: fromEmail,
      fromName: fromName,
      libraryPhone: libraryPhone,
    );
  }

  /// Factory constructor cho Mailgun
  factory EmailService.mailgun({
    required String username,
    required String password,
    required String fromEmail,
    String fromName = 'Thư viện PTIT',
    String libraryPhone = '0123456789',
  }) {
    final smtpServer = SmtpServer(
      'smtp.mailgun.org',
      port: 587,
      username: username,
      password: password,
    );
    return EmailService(
      smtpServer: smtpServer,
      fromEmail: fromEmail,
      fromName: fromName,
      libraryPhone: libraryPhone,
    );
  }

  /// Gửi email cơ bản
  Future<EmailResult> sendEmail({
    required String to,
    required String subject,
    required String body,
    bool isHtml = false,
  }) async {
    try {
      final message = Message()
        ..from = Address(_fromEmail, _fromName)
        ..recipients.add(to)
        ..subject = subject;

      if (isHtml) {
        message.html = body;
      } else {
        message.text = body;
      }

      await send(message, _smtpServer);
      
      return EmailResult(
        success: true,
        message: 'Email sent successfully',
        sentAt: DateTime.now(),
        recipient: to,
      );
    } catch (e) {
      return EmailResult(
        success: false,
        message: 'Failed to send email: $e',
        error: e.toString(),
        recipient: to,
      );
    }
  }

  /// Gửi email thông báo sắp đến hạn (2-3 ngày trước)
  Future<EmailResult> sendUpcomingDueNotification(BorrowCard card) async {
    if (card.borrowerEmail == null || card.borrowerEmail!.isEmpty) {
      return EmailResult(
        success: false,
        message: 'No email address provided',
        error: 'borrowerEmail is null or empty',
        recipient: '',
      );
    }

    final daysUntilDue = card.expectedReturnDate.difference(DateTime.now()).inDays;
    final dateFormat = DateFormat('dd/MM/yyyy');

    final subject = '[Thư viện PTIT] Nhắc nhở: Sách sắp đến hạn trả';
    final body = '''
Xin chào ${card.borrowerName},

Sách "${card.bookName}" mà bạn đang mượn sẽ đến hạn trả vào ngày ${dateFormat.format(card.expectedReturnDate)}.

Thông tin chi tiết:
- Mã sách: ${card.bookCode ?? 'N/A'}
- Ngày mượn: ${dateFormat.format(card.borrowDate)}
- Ngày trả dự kiến: ${dateFormat.format(card.expectedReturnDate)}
- Số ngày còn lại: $daysUntilDue ngày

Vui lòng trả sách đúng hạn để tránh bị phạt.

Trân trọng,
$_fromName
Liên hệ: $_libraryPhone
''';

    return await sendEmail(
      to: card.borrowerEmail!,
      subject: subject,
      body: body,
    );
  }

  /// Gửi email thông báo đến hạn hôm nay
  Future<EmailResult> sendDueTodayNotification(BorrowCard card) async {
    if (card.borrowerEmail == null || card.borrowerEmail!.isEmpty) {
      return EmailResult(
        success: false,
        message: 'No email address provided',
        error: 'borrowerEmail is null or empty',
        recipient: '',
      );
    }

    final dateFormat = DateFormat('dd/MM/yyyy');

    final subject = '[Thư viện PTIT] NHẮC NHỞ: Sách đến hạn trả hôm nay';
    final body = '''
Xin chào ${card.borrowerName},

Sách "${card.bookName}" đến hạn trả hôm nay (${dateFormat.format(card.expectedReturnDate)}).

Thông tin chi tiết:
- Mã sách: ${card.bookCode ?? 'N/A'}
- Ngày mượn: ${dateFormat.format(card.borrowDate)}

Vui lòng trả sách trong ngày hôm nay để tránh bị phạt quá hạn.

Liên hệ: $_libraryPhone

Trân trọng,
$_fromName
''';

    return await sendEmail(
      to: card.borrowerEmail!,
      subject: subject,
      body: body,
    );
  }

  /// Gửi email thông báo quá hạn
  Future<EmailResult> sendOverdueNotification(BorrowCard card) async {
    if (card.borrowerEmail == null || card.borrowerEmail!.isEmpty) {
      return EmailResult(
        success: false,
        message: 'No email address provided',
        error: 'borrowerEmail is null or empty',
        recipient: '',
      );
    }

    final daysOverdue = card.daysOverdue;
    final dateFormat = DateFormat('dd/MM/yyyy');

    final subject = '[Thư viện PTIT] ⚠️ CẢNH BÁO: Sách quá hạn $daysOverdue ngày';
    final body = '''
Xin chào ${card.borrowerName},

Sách "${card.bookName}" đã quá hạn trả $daysOverdue ngày.

Thông tin chi tiết:
- Mã sách: ${card.bookCode ?? 'N/A'}
- Ngày mượn: ${dateFormat.format(card.borrowDate)}
- Ngày trả dự kiến: ${dateFormat.format(card.expectedReturnDate)}
- Số ngày quá hạn: $daysOverdue ngày

⚠️ Vui lòng trả sách ngay để tránh bị phạt nặng hơn.

Liên hệ khẩn cấp: $_libraryPhone

Trân trọng,
$_fromName
''';

    return await sendEmail(
      to: card.borrowerEmail!,
      subject: subject,
      body: body,
    );
  }

  /// Gửi email reset mật khẩu
  Future<EmailResult> sendPasswordResetEmail({
    required String to,
    required String userName,
    required String resetCode,
  }) async {
    final subject = '[Thư viện PTIT] 🔐 Mã xác thực đặt lại mật khẩu';
    final body = '''
Xin chào $userName,

Bạn đã yêu cầu đặt lại mật khẩu cho tài khoản Thư viện PTIT.

Mã xác thực của bạn là:

🔑 $resetCode

Mã này có hiệu lực trong 15 phút.

⚠️ Lưu ý:
- Không chia sẻ mã này với bất kỳ ai
- Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này

Liên hệ hỗ trợ: $_libraryPhone

Trân trọng,
$_fromName
''';

    return await sendEmail(
      to: to,
      subject: subject,
      body: body,
    );
  }

  /// Test kết nối SMTP
  Future<bool> testConnection() async {
    try {
      final message = Message()
        ..from = Address(_fromEmail, _fromName)
        ..recipients.add(_fromEmail)
        ..subject = 'Test Connection'
        ..text = 'This is a test email to verify SMTP connection.';

      await send(message, _smtpServer);
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Kết quả gửi email
class EmailResult {
  final bool success;
  final String message;
  final String? error;
  final DateTime? sentAt;
  final String recipient;

  EmailResult({
    required this.success,
    required this.message,
    this.error,
    this.sentAt,
    required this.recipient,
  });

  @override
  String toString() {
    return 'EmailResult(success: $success, message: $message, recipient: $recipient)';
  }
}
