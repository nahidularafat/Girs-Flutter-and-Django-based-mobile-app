import 'package:flutter/material.dart';

/// App Localizations — supports English (en) and Bengali (bn)
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isBangla => locale.languageCode == 'bn';

  // ─── App ──────────────────────────────────────────────────────────────────
  String get appName => isBangla ? 'গার্লস' : 'Girls';
  String get appTagline => isBangla
      ? 'আপনার স্বাস্থ্য, আপনার যত্ন 🌸'
      : 'Your health, your care 🌸';

  // ─── Onboarding ───────────────────────────────────────────────────────────
  String get welcomeTitle1 => isBangla ? 'আপনার সাইকেল ট্র্যাক করুন' : 'Track Your Cycle';
  String get welcomeBody1 => isBangla
      ? 'এআই-চালিত পূর্বাভাস দিয়ে পিরিয়ড এবং সার্বিক স্বাস্থ্য ট্র্যাক করুন।'
      : 'Track your periods and overall health with AI-powered predictions.';
  String get welcomeTitle2 => isBangla ? 'ব্যক্তিগত গাইডেন্স' : 'Personalized Guidance';
  String get welcomeBody2 => isBangla
      ? 'আপনার সাইকেল ফেজ অনুযায়ী প্রতিদিনের স্বাস্থ্য টিপস পান।'
      : 'Get daily health tips tailored to your cycle phase.';
  String get welcomeTitle3 => isBangla ? 'গোপনীয় ও নিরাপদ' : 'Private & Secure';
  String get welcomeBody3 => isBangla
      ? 'আপনার তথ্য এনক্রিপ্টেড এবং সম্পূর্ণ গোপনীয়।'
      : 'Your data is encrypted and completely private.';
  String get skip => isBangla ? 'বাদ দিন' : 'Skip';
  String get next => isBangla ? 'পরবর্তী' : 'Next';
  String get getStarted => isBangla ? 'শুরু করুন' : 'Get Started';
  String get signInWithGoogle => isBangla ? 'Google দিয়ে সাইন ইন' : 'Continue with Google';
  String get continueWithPhone => isBangla ? 'ফোন নম্বর দিয়ে চালিয়ে যান' : 'Continue with Phone Number';
  String get orText => isBangla ? 'অথবা' : 'or';
  String get enterMobileNumber => isBangla ? 'আপনার মোবাইল নম্বর দিন' : 'Enter your mobile number';
  String get mobileHint => isBangla ? '+880 1X XXXX XXXX' : '+880 1X XXXX XXXX';
  String get sendOTP => isBangla ? 'ওটিপি পাঠান' : 'Send OTP';
  String get enterOTP => isBangla ? 'ভেরিফিকেশন কোড দিন' : 'Enter verification code';
  String get verifyOTP => isBangla ? 'যাচাই করুন' : 'Verify OTP';
  String get resendOTP => isBangla ? 'OTP পুনরায় পাঠান' : 'Resend OTP';
  String get resendIn => isBangla ? 'পুনরায় পাঠান' : 'Resend code in';
  String get seconds => isBangla ? 'সেকেন্ডে' : 's';

  // ─── Onboarding Steps ─────────────────────────────────────────────────────
  String get whereAreYou => isBangla ? 'আপনি কোথায় আছেন?' : 'Where are you?';
  String get locationSubtitle => isBangla
      ? 'আঞ্চলিক স্বাস্থ্য পরামর্শ এবং কাছের ক্লিনিক খুঁজে পেতে।'
      : 'For regional health tips and finding nearby clinics.';
  String get enableLocation => isBangla ? 'লোকেশন চালু করুন' : 'Enable Location';
  String get skipForNow => isBangla ? 'এখনের জন্য বাদ দিন' : 'Skip for now';
  String get howOldAreYou => isBangla ? 'আপনার বয়স কত?' : 'How old are you?';
  String get yourAge => isBangla ? 'বয়স' : 'Age';
  String get continueBtn => isBangla ? 'চালিয়ে যান' : 'Continue';
  String get maritalStatus => isBangla ? 'বৈবাহিক অবস্থা' : 'Marital Status';
  String get single => isBangla ? 'অবিবাহিত' : 'Single';
  String get married => isBangla ? 'বিবাহিত' : 'Married';
  String get preferNotToSay => isBangla ? 'বলতে চাই না' : 'Prefer not to say';
  String get lastPeriodDate => isBangla ? 'শেষ পিরিয়ড কবে শুরু হয়েছিল?' : 'When did your last period start?';
  String get selectDate => isBangla ? 'তারিখ নির্বাচন করুন' : 'Select Date';
  String get cycleLength => isBangla ? 'সাধারণত আপনার সাইকেল কতদিনের?' : 'How long is your usual cycle?';
  String get days => isBangla ? 'দিন' : 'days';
  String get notifications => isBangla ? 'নোটিফিকেশন চালু রাখবেন?' : 'Enable Notifications?';
  String get notificationsSubtitle => isBangla
      ? 'পিরিয়ড রিমাইন্ডার এবং স্বাস্থ্য টিপস পান।'
      : 'Get period reminders and health tips.';
  String get allDoneLetsGo => isBangla ? 'সব হয়ে গেছে! শুরু করুন 🎉' : 'All done! Let\'s go 🎉';

  // ─── Home ─────────────────────────────────────────────────────────────────
  String get today => isBangla ? 'আজ' : 'Today';
  String get day => isBangla ? 'দিন' : 'DAY';
  String get daysAway => isBangla ? 'দিন বাকি' : 'days away';
  String get nextPeriod => isBangla ? 'পরবর্তী পিরিয়ড' : 'Next Period';
  String get fertileWindow => isBangla ? 'প্রজনন উইন্ডো' : 'Fertile Window';
  String get logToday => isBangla ? 'আজ লগ করুন' : 'Log Today';
  String get flowSymptomsNotes => isBangla ? 'রক্তপ্রবাহ, লক্ষণ ও নোট' : 'Flow, symptoms & notes';
  String get todayGuidance => isBangla ? 'আজকের গাইডেন্স' : "Today's Guidance";
  String get welcome => isBangla ? 'স্বাগতম!' : 'Welcome!';
  String get logFirstPeriod => isBangla
      ? 'ট্র্যাকিং শুরু করতে আপনার প্রথম পিরিয়ড লগ করুন।'
      : 'Log your first period to start tracking your cycle.';
  String get logFirstPeriodBtn => isBangla ? 'প্রথম পিরিয়ড লগ করুন' : 'Log First Period';

  // ─── Phase Labels ─────────────────────────────────────────────────────────
  String get menstrual => isBangla ? '🌸 মাসিক' : '🌸 Menstrual';
  String get follicular => isBangla ? '🌱 ফলিকুলার' : '🌱 Follicular';
  String get ovulation => isBangla ? '✨ ডিম্বস্ফোটন' : '✨ Ovulation';
  String get luteal => isBangla ? '🌙 লুটিয়াল' : '🌙 Luteal';

  String phaseLabel(String phase) {
    switch (phase) {
      case 'menstrual': return menstrual;
      case 'follicular': return follicular;
      case 'ovulation': return ovulation;
      case 'luteal': return luteal;
      default: return phase;
    }
  }

  // ─── Calendar ─────────────────────────────────────────────────────────────
  String get calendar => isBangla ? 'ক্যালেন্ডার' : 'Calendar';
  String get cycleLegend => isBangla ? 'সাইকেল লেজেন্ড' : 'Cycle Legend';
  String get periodDays => isBangla ? 'পিরিয়ডের দিন' : 'Period days';
  String get predictedPeriod => isBangla ? 'পূর্বানুমানিত পিরিয়ড' : 'Predicted period';
  String get fertileWindowLegend => isBangla ? 'প্রজনন উইন্ডো' : 'Fertile window';
  String get ovulationLegend => isBangla ? 'ডিম্বস্ফোটন' : 'Ovulation';

  // ─── History ──────────────────────────────────────────────────────────────
  String get history => isBangla ? 'ইতিহাস' : 'History';
  String get cycleHistory => isBangla ? 'সাইকেল ইতিহাস' : 'Cycle History';
  String get avgCycleLength => isBangla ? 'গড় সাইকেল দৈর্ঘ্য' : 'Avg Cycle Length';
  String get totalCycles => isBangla ? 'মোট সাইকেল' : 'Total Cycles';

  // ─── Symptoms ─────────────────────────────────────────────────────────────
  String get logSymptoms => isBangla ? 'লক্ষণ লগ করুন' : 'Log Symptoms';
  String get howIsYourFlow => isBangla ? 'রক্তপ্রবাহ কেমন?' : 'How is your flow?';
  String get none => isBangla ? 'নেই' : 'None';
  String get light => isBangla ? 'হালকা' : 'Light';
  String get medium => isBangla ? 'মাঝারি' : 'Medium';
  String get heavy => isBangla ? 'ভারী' : 'Heavy';
  String get howAreYouFeeling => isBangla ? 'আপনি কেমন অনুভব করছেন?' : 'How are you feeling?';
  String get notes => isBangla ? 'নোট' : 'Notes';
  String get addNotes => isBangla ? 'আজকের অনুভূতি লিখুন...' : 'Write how you feel today...';
  String get saveLog => isBangla ? 'লগ সংরক্ষণ করুন' : 'Save Log';
  String get cramps => isBangla ? 'ব্যথা' : 'Cramps';
  String get bloating => isBangla ? 'ফোলাভাব' : 'Bloating';
  String get headache => isBangla ? 'মাথাব্যথা' : 'Headache';
  String get fatigue => isBangla ? 'ক্লান্তি' : 'Fatigue';
  String get moodSwings => isBangla ? 'মেজাজ পরিবর্তন' : 'Mood Swings';
  String get backPain => isBangla ? 'পিঠে ব্যথা' : 'Back Pain';
  String get nausea => isBangla ? 'বমিভাব' : 'Nausea';
  String get acne => isBangla ? 'ব্রণ' : 'Acne';
  String get breastTenderness => isBangla ? 'বুকে অস্বস্তি' : 'Breast Tenderness';
  String get insomnia => isBangla ? 'অনিদ্রা' : 'Insomnia';
  String get anxiety => isBangla ? 'উদ্বেগ' : 'Anxiety';
  String get cravings => isBangla ? 'খাওয়ার ইচ্ছা' : 'Cravings';

  // ─── Profile / Settings ───────────────────────────────────────────────────
  String get profile => isBangla ? 'প্রোফাইল' : 'Profile';
  String get settings => isBangla ? 'সেটিংস' : 'Settings';
  String get darkMode => isBangla ? 'ডার্ক মোড' : 'Dark Mode';
  String get language => isBangla ? 'ভাষা' : 'Language';
  String get notifications2 => isBangla ? 'নোটিফিকেশন' : 'Notifications';
  String get privacy => isBangla ? 'গোপনীয়তা' : 'Privacy';
  String get dataExport => isBangla ? 'ডেটা এক্সপোর্ট' : 'Export Data';
  String get deleteAccount => isBangla ? 'অ্যাকাউন্ট মুছুন' : 'Delete Account';
  String get signOut => isBangla ? 'সাইন আউট' : 'Sign Out';
  String get english => 'English';
  String get bangla => 'বাংলা';

  // ─── Navigation ───────────────────────────────────────────────────────────
  String get navHome => isBangla ? 'হোম' : 'Home';
  String get navCalendar => isBangla ? 'ক্যালেন্ডার' : 'Calendar';
  String get navHistory => isBangla ? 'ইতিহাস' : 'History';
  String get navProfile => isBangla ? 'প্রোফাইল' : 'Profile';

  // ─── General ──────────────────────────────────────────────────────────────
  String get couldNotLoad => isBangla ? 'তথ্য লোড করা যায়নি' : 'Could not load data';
  String get retry => isBangla ? 'আবার চেষ্টা করুন' : 'Retry';
  String get save => isBangla ? 'সংরক্ষণ' : 'Save';
  String get cancel => isBangla ? 'বাতিল' : 'Cancel';
  String get disclaimer => isBangla
      ? 'এটি সাধারণ স্বাস্থ্য পরামর্শ, চিকিৎসা পরামর্শ নয়। দীর্ঘস্থায়ী সমস্যার জন্য ডাক্তারের পরামর্শ নিন।'
      : 'This is general wellness guidance, not medical advice. For persistent symptoms, please consult a doctor.';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'bn'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension for easy access
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
