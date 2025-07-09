import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'controllers/sign_in_controller.dart';
import 'controllers/dashboard_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_screen.dart';
import 'screens/courier_insights_screen.dart';
import 'screens/courier_companies_screen.dart';
import 'screens/add_courier_company_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/add_notification_screen.dart';
import 'screens/menu.dart';
import 'screens/help_videos_screen.dart';
import 'screens/order_list_screen.dart';
import 'screens/report.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;
    
    if (rememberMe) {
      // Check if we have saved credentials
      final savedEmail = prefs.getString('remember_email') ?? '';
      final savedPassword = prefs.getString('remember_password') ?? '';
      
      if (savedEmail.isNotEmpty && savedPassword.isNotEmpty) {
        // Try to login with saved credentials
        final authService = Get.find<AuthService>();
        final loginSuccess = await authService.login(savedEmail, savedPassword);
        
        if (loginSuccess) {
          return DashboardScreen();
        } else {
          // Login failed, clear saved credentials and go to onboarding
          await prefs.remove('remember_email');
          await prefs.remove('remember_password');
          await prefs.setBool('remember_me', false);
          return OnboardingScreen();
        }
      } else {
        // No saved credentials, go to onboarding
        return OnboardingScreen();
      }
    } else {
      // Remember me not checked, go to onboarding
      return OnboardingScreen();
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Orio',
      initialBinding: BindingsBuilder(() {
        Get.put(AuthService());
        Get.put(SignInController());
        Get.put(DashboardController());
      }),
      getPages: [
        GetPage(name: '/dashboard', page: () => DashboardScreen()),
        GetPage(name: '/order-list', page: () => OrderListScreen()),
        GetPage(name: '/reports', page: () => ReportsScreen()),
        GetPage(name: '/courier-companies', page: () => CourierCompaniesScreen()),
        GetPage(name: '/add-courier', page: () => AddCourierCompanyScreen()),
        GetPage(name: '/notifications', page: () => NotificationScreen()),
        GetPage(name: '/add-notification', page: () => AddNotificationScreen()),
        GetPage(name: '/edit-notification', page: () => AddNotificationScreen(isEdit: true)),
        GetPage(name: '/courier-insights', page: () => CourierInsightsScreen()),
        GetPage(name: '/menu', page: () => MenuScreen()),
        GetPage(name: '/help-videos', page: () => HelpVideosScreen()),
        GetPage(name: '/profile', page: () => ProfileScreen()),
      ],
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => Scaffold(
          body: Center(child: Text('Page not found or failed to build', style: TextStyle(fontSize: 20))),
        ),
      ),
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF007AFF)),
        useMaterial3: true,
      ),
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data!;
          }
          // Show splash while loading
          return const SplashScreen();
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
