import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'services/auth_service.dart';
import 'services/rules_service.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/sign_in_screen.dart';
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
import 'controllers/help_video_controller.dart';

void main() {
  runApp(const MyApp());
}

class InitialScreenSelector extends StatefulWidget {
  const InitialScreenSelector({Key? key}) : super(key: key);

  @override
  State<InitialScreenSelector> createState() => _InitialScreenSelectorState();
}

class _InitialScreenSelectorState extends State<InitialScreenSelector> {
  Widget? _initialScreen;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determineInitialScreen();
  }

  Future<void> _determineInitialScreen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('remember_me') ?? false;
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      print('🔍 Initial Screen Check:');
      print('   Remember Me: $rememberMe');
      print('   Is Logged In: $isLoggedIn');
      
      // Debug: Print all relevant SharedPreferences values
      final userId = prefs.getString('user_id') ?? 'null';
      final email = prefs.getString('email') ?? 'null';
      final rememberEmail = prefs.getString('remember_email') ?? 'null';
      print('   Debug - user_id: $userId');
      print('   Debug - email: $email');
      print('   Debug - remember_email: $rememberEmail');
      
      // First, check if user is already logged in (regardless of Remember Me)
      if (isLoggedIn) {
        print('   ✅ User is logged in, loading user data...');
        final authService = Get.find<AuthService>();
        final user = await authService.loadUserData();
        
        if (user != null) {
          print('   ✅ User data loaded successfully, going to Dashboard');
          setState(() {
            _initialScreen = DashboardScreen();
            _isLoading = false;
          });
          return;
        } else {
          print('   ❌ User data couldn\'t be loaded, clearing login status');
          // User data couldn't be loaded, clear login status
          await prefs.setBool('is_logged_in', false);
        }
      }
      
      // Check Remember Me scenarios
      if (rememberMe) {
        print('   🔄 Remember Me enabled, checking saved credentials...');
        // User has "Remember Me" enabled but not logged in
        // Check if we have saved credentials and try to login
        final savedEmail = prefs.getString('remember_email') ?? '';
        final savedPassword = prefs.getString('remember_password') ?? '';
        
        if (savedEmail.isNotEmpty && savedPassword.isNotEmpty) {
          print('   🔄 Attempting auto-login with saved credentials...');
          final authService = Get.find<AuthService>();
          final loginSuccess = await authService.login(savedEmail, savedPassword);
          
          if (loginSuccess) {
          
            setState(() {
              _initialScreen = DashboardScreen();
              _isLoading = false;
            });
            return;
          } else {
            
            // Login failed, clear saved credentials
            await prefs.remove('remember_email');
            await prefs.remove('remember_password');
            await prefs.setBool('remember_me', false);
          }
        } else {
         
        }
      }
      
     
      setState(() {
        _initialScreen = OnboardingScreen();
        _isLoading = false;
      });
    } catch (e) {
      
      setState(() {
        _initialScreen = OnboardingScreen();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }
    return _initialScreen ?? const OnboardingScreen();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(
            textScaler: TextScaler.noScaling, 
            boldText: false,
            devicePixelRatio: MediaQuery.of(context).devicePixelRatio * 0.5,
          ),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Orio',
      initialBinding: BindingsBuilder(() {
        Get.put(AuthService(), permanent: true);
        Get.put(RulesService(Get.find<AuthService>()), permanent: true);
        Get.put(SignInController());
        Get.put(DashboardController());
        Get.put(HelpVideoController());
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
        GetPage(name: '/sign-in', page: () => SignInScreen()),
        GetPage(name: '/onboarding', page: () => OnboardingScreen()),
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
        // reload" button in a Flutter-supported IDE, or press "r" if the command
        // line to start the app).
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
      home: const InitialScreenSelector(),
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
