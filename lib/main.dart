import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_epasien/blocs/auth/auth_bloc.dart';
import 'package:flutter_epasien/blocs/auth/auth_event.dart';
import 'package:flutter_epasien/blocs/auth/auth_state.dart';
import 'package:flutter_epasien/blocs/jadwal/jadwal_bloc.dart';
import 'package:flutter_epasien/blocs/booking/booking_bloc.dart';
import 'package:flutter_epasien/blocs/lab/lab_bloc.dart';
import 'package:flutter_epasien/blocs/profile/profile_bloc.dart';
import 'package:flutter_epasien/blocs/news/news_bloc.dart';
import 'package:flutter_epasien/blocs/rekam_medis/rekam_medis_bloc.dart';
import 'package:flutter_epasien/blocs/surat_kontrol/surat_kontrol_bloc.dart';
import 'package:flutter_epasien/blocs/kamar/kamar_bloc.dart';
import 'package:flutter_epasien/blocs/radiology/radiology_bloc.dart';
import 'package:flutter_epasien/services/news_service.dart';
import 'package:flutter_epasien/services/api_service.dart';
import 'package:flutter_epasien/services/rekam_medis_service.dart';
import 'package:flutter_epasien/config/theme.dart';
import 'package:flutter_epasien/screens/login_screen.dart';
import 'package:flutter_epasien/screens/home_screen.dart';
import 'package:flutter_epasien/widgets/loading_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc()..add(const CheckAuthStatus()),
        ),
        BlocProvider(create: (context) => JadwalBloc()),
        BlocProvider(create: (context) => BookingBloc()),
        BlocProvider(create: (context) => LabBloc()),
        BlocProvider(create: (context) => ProfileBloc()),
        BlocProvider(create: (context) => NewsBloc(newsService: NewsService())),
        BlocProvider(
          create: (context) =>
              RekamMedisBloc(rekamMedisService: RekamMedisService()),
        ),
        BlocProvider(create: (context) => SuratKontrolBloc()),
        BlocProvider(create: (context) => KamarBloc(apiService: ApiService())),
        BlocProvider(create: (context) => RadiologyBloc()),
      ],
      child: MaterialApp(
        title: 'SiSehat Bau-Bau',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(body: LoadingWidget(message: 'Memuat...'));
        } else if (state is AuthAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
