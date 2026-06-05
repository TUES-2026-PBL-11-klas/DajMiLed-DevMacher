import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:devmatch_client/auth.dart' as auth;
import 'package:devmatch_client/screens/login_screen.dart';
import 'package:devmatch_client/screens/register_screen.dart';
import 'package:devmatch_client/widgets/dm_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class _HomeStub extends StatelessWidget {
  const _HomeStub();
  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('Home'));
}

GoRouter _router(Widget startScreen, String startPath) => GoRouter(
      initialLocation: startPath,
      routes: [
        GoRoute(path: startPath, builder: (_, __) => startScreen),
        GoRoute(path: '/', builder: (_, __) => const _HomeStub()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ],
    );

Widget _app(Widget screen, String path) => ShadApp.custom(
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadZincColorScheme.light(),
      ),
      appBuilder: (context) => MaterialApp.router(
        routerConfig: _router(screen, path),
        builder: (context, child) => ShadAppBuilder(child: child!),
      ),
    );

void _mockStorage() {
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async => null);
}

// ── Minimal HTTP override — returns a fake successful auth response ──
class _FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
}

class _FakeHttpClient implements HttpClient {
  @override bool autoUncompress = true;
  @override Duration? connectionTimeout;
  @override Duration idleTimeout = const Duration(seconds: 15);
  @override int? maxConnectionsPerHost;
  @override String? userAgent;
  @override void close({bool force = false}) {}
  @override set authenticate(Future<bool> Function(Uri, String, String?)? f) {}
  @override set authenticateProxy(Future<bool> Function(String, int, String, String?)? f) {}
  @override set badCertificateCallback(bool Function(X509Certificate, String, int)? f) {}
  @override set findProxy(String Function(Uri)? f) {}
  @override set connectionFactory(Future<ConnectionTask<Socket>> Function(Uri, String?, int?)? f) {}
  @override set keyLog(Function(String line)? f) {}
  @override void addCredentials(Uri u, String r, HttpClientCredentials c) {}
  @override void addProxyCredentials(String h, int p, String r, HttpClientCredentials c) {}
  @override Future<HttpClientRequest> delete(String h, int p, String path) => throw UnimplementedError();
  @override Future<HttpClientRequest> deleteUrl(Uri url) => throw UnimplementedError();
  @override Future<HttpClientRequest> get(String h, int p, String path) => throw UnimplementedError();
  @override Future<HttpClientRequest> getUrl(Uri url) => throw UnimplementedError();
  @override Future<HttpClientRequest> head(String h, int p, String path) => throw UnimplementedError();
  @override Future<HttpClientRequest> headUrl(Uri url) => throw UnimplementedError();
  @override Future<HttpClientRequest> open(String m, String h, int p, String path) => throw UnimplementedError();
  @override Future<HttpClientRequest> openUrl(String method, Uri url) async => _FakeHttpRequest(url);
  @override Future<HttpClientRequest> patch(String h, int p, String path) => throw UnimplementedError();
  @override Future<HttpClientRequest> patchUrl(Uri url) => throw UnimplementedError();
  @override Future<HttpClientRequest> post(String h, int p, String path) => throw UnimplementedError();
  @override Future<HttpClientRequest> postUrl(Uri url) async => _FakeHttpRequest(url);
  @override Future<HttpClientRequest> put(String h, int p, String path) => throw UnimplementedError();
  @override Future<HttpClientRequest> putUrl(Uri url) async => _FakeHttpRequest(url);
}

class _FakeHttpRequest implements HttpClientRequest {
  final Uri _uri;
  _FakeHttpRequest(this._uri);

  @override bool bufferOutput = true;
  @override int contentLength = -1;
  @override bool followRedirects = true;
  @override int maxRedirects = 5;
  @override bool persistentConnection = true;
  @override String get method => 'POST';
  @override Uri get uri => _uri;
  @override List<Cookie> get cookies => [];
  @override HttpConnectionInfo? get connectionInfo => null;
  @override HttpHeaders get headers => _FakeHttpHeaders();
  @override Encoding encoding = utf8;
  @override Future<HttpClientResponse> get done => close();
  @override void abort([Object? exception, StackTrace? stackTrace]) {}
  @override void add(List<int> data) {}
  @override void addError(Object e, [StackTrace? s]) {}
  @override Future addStream(Stream<List<int>> stream) async {}
  @override Future<HttpClientResponse> close() async {
    // login expects 200, register expects 201
    final code = _uri.path.contains('login') ? 200 : 201;
    return _FakeHttpResponse(code);
  }
  @override Future flush() async {}
  @override void write(Object? obj) {}
  @override void writeAll(Iterable<Object?> objects, [String sep = '']) {}
  @override void writeCharCode(int charCode) {}
  @override void writeln([Object? obj = '']) {}
}

class _FakeHttpResponse extends Stream<List<int>> implements HttpClientResponse {
  static final _kBody = utf8.encode(
      jsonEncode({'token': 'fake-token', 'user': <String, dynamic>{'id': 1}}));

  final int _statusCode;
  _FakeHttpResponse(this._statusCode);

  @override int get statusCode => _statusCode;
  @override String get reasonPhrase => 'Created';
  @override int get contentLength => _kBody.length;
  @override bool get isRedirect => false;
  @override bool get persistentConnection => false;
  @override List<RedirectInfo> get redirects => [];
  @override X509Certificate? get certificate => null;
  @override HttpConnectionInfo? get connectionInfo => null;
  @override HttpHeaders get headers => _FakeHttpHeaders();
  @override List<Cookie> get cookies => [];
  @override HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override Future<Socket> detachSocket() => throw UnimplementedError();
  @override Future<HttpClientResponse> redirect([String? method, Uri? url, bool? followLoops]) =>
      throw UnimplementedError();

  @override
  StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream.value(_kBody).listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

class _FakeHttpHeaders implements HttpHeaders {
  @override void add(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override void clear() {}
  @override void forEach(void Function(String, List<String>) action) {}
  @override void noFolding(String name) {}
  @override void remove(String name, Object value) {}
  @override void removeAll(String name) {}
  @override void set(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override String? value(String name) => null;
  @override List<String>? operator [](String name) => null;
  void operator []=(String name, Object value) {}
  @override bool chunkedTransferEncoding = false;
  @override int contentLength = -1;
  @override ContentType? contentType;
  @override DateTime? date;
  @override DateTime? expires;
  @override String? host;
  @override DateTime? ifModifiedSince;
  @override bool persistentConnection = false;
  int? _port;
  @override int? get port => _port;
  @override set port(int? value) => _port = value;
}

void main() {
  setUp(() {
    auth.loggedIn = false;
    _mockStorage();
    HttpOverrides.global = _FakeHttpOverrides();
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  group('LoginScreen', () {
    testWidgets('renders sign in heading', (tester) async {
      await tester.pumpWidget(_app(const LoginScreen(), '/login'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in'), findsWidgets);
    });

    testWidgets('sign in navigates to home', (tester) async {
      await tester.pumpWidget(_app(const LoginScreen(), '/login'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(DmBtn, 'Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });
  });

  group('RegisterScreen', () {
    testWidgets('renders first name step', (tester) async {
      await tester.pumpWidget(_app(const RegisterScreen(), '/register'));
      await tester.pumpAndSettle();
      expect(find.textContaining('first name'), findsOneWidget);
    });

    testWidgets('create account navigates to home', (tester) async {
      await tester.pumpWidget(_app(const RegisterScreen(), '/register'));
      await tester.pumpAndSettle();

      // Tap Continue 4 times: steps 0→1, 1→2, 2→3, then step 3 submits
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.widgetWithText(DmBtn, 'Continue'));
        await tester.pumpAndSettle();
      }

      expect(find.text('Home'), findsOneWidget);
    });
  });
}
