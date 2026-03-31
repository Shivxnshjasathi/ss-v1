import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Sampatti Bazar'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @myProperties.
  ///
  /// In en, this message translates to:
  /// **'My Properties'**
  String get myProperties;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @searchProperties.
  ///
  /// In en, this message translates to:
  /// **'Search Properties...'**
  String get searchProperties;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcome;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'BUY'**
  String get buy;

  /// No description provided for @rent.
  ///
  /// In en, this message translates to:
  /// **'RENT'**
  String get rent;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'LIST'**
  String get list;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'SERVICES'**
  String get services;

  /// No description provided for @loan.
  ///
  /// In en, this message translates to:
  /// **'LOAN'**
  String get loan;

  /// No description provided for @construct.
  ///
  /// In en, this message translates to:
  /// **'CONSTRUCT'**
  String get construct;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'LEGAL'**
  String get legal;

  /// No description provided for @movers.
  ///
  /// In en, this message translates to:
  /// **'Movers'**
  String get movers;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'SEE ALL'**
  String get seeAll;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'WELCOME TO'**
  String get welcomeTo;

  /// No description provided for @sampattiBazar.
  ///
  /// In en, this message translates to:
  /// **'SAMPATTI BAZAR'**
  String get sampattiBazar;

  /// No description provided for @emailLoginHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to continue'**
  String get emailLoginHint;

  /// No description provided for @phoneLoginHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to get started'**
  String get phoneLoginHint;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'MOBILE NUMBER'**
  String get mobileNumber;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'EMAIL ADDRESS'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get password;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @getOtp.
  ///
  /// In en, this message translates to:
  /// **'Get OTP'**
  String get getOtp;

  /// No description provided for @usePhone.
  ///
  /// In en, this message translates to:
  /// **'Use Phone Number instead'**
  String get usePhone;

  /// No description provided for @useEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with Email instead'**
  String get useEmail;

  /// No description provided for @agreementText.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our'**
  String get agreementText;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @verifyYour.
  ///
  /// In en, this message translates to:
  /// **'VERIFY YOUR'**
  String get verifyYour;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'NUMBER'**
  String get number;

  /// No description provided for @otpEntryHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to'**
  String get otpEntryHint;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive code? '**
  String get didntReceiveCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in'**
  String get resendIn;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get completeProfile;

  /// No description provided for @welcomeToSampatti.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Sampatti Bazar!'**
  String get welcomeToSampatti;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us a bit about yourself to personalize your experience.'**
  String get onboardingSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'PHONE NUMBER'**
  String get phoneNumber;

  /// No description provided for @cityLocation.
  ///
  /// In en, this message translates to:
  /// **'CITY / LOCATION'**
  String get cityLocation;

  /// No description provided for @yourRole.
  ///
  /// In en, this message translates to:
  /// **'YOUR ROLE'**
  String get yourRole;

  /// No description provided for @completeSetup.
  ///
  /// In en, this message translates to:
  /// **'Complete Setup'**
  String get completeSetup;

  /// No description provided for @consumerBuyer.
  ///
  /// In en, this message translates to:
  /// **'Consumer / Buyer'**
  String get consumerBuyer;

  /// No description provided for @builderAgent.
  ///
  /// In en, this message translates to:
  /// **'Builder / Agent'**
  String get builderAgent;

  /// No description provided for @constructionPartner.
  ///
  /// In en, this message translates to:
  /// **'Construction Partner'**
  String get constructionPartner;

  /// No description provided for @legalAdvisor.
  ///
  /// In en, this message translates to:
  /// **'Legal Advisor'**
  String get legalAdvisor;

  /// No description provided for @materialVendor.
  ///
  /// In en, this message translates to:
  /// **'Material Vendor'**
  String get materialVendor;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterName;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get enterPhone;

  /// No description provided for @enterCity.
  ///
  /// In en, this message translates to:
  /// **'Please enter your city'**
  String get enterCity;

  /// No description provided for @homeLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeLabel;

  /// No description provided for @servicesLabel.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get servicesLabel;

  /// No description provided for @savedLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedLabel;

  /// No description provided for @messagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesLabel;

  /// No description provided for @servicesHub.
  ///
  /// In en, this message translates to:
  /// **'Services Hub'**
  String get servicesHub;

  /// No description provided for @financialEcosystem.
  ///
  /// In en, this message translates to:
  /// **'Financial\nEcosystem'**
  String get financialEcosystem;

  /// No description provided for @servicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Secure, end-to-end property solutions\npowered by Sampatti.'**
  String get servicesSubtitle;

  /// No description provided for @homeLoans.
  ///
  /// In en, this message translates to:
  /// **'Home Loans'**
  String get homeLoans;

  /// No description provided for @instantApproval.
  ///
  /// In en, this message translates to:
  /// **'Instant Approval'**
  String get instantApproval;

  /// No description provided for @construction.
  ///
  /// In en, this message translates to:
  /// **'Construction'**
  String get construction;

  /// No description provided for @topContractors.
  ///
  /// In en, this message translates to:
  /// **'Top Contractors'**
  String get topContractors;

  /// No description provided for @safeRelocation.
  ///
  /// In en, this message translates to:
  /// **'Safe Relocation'**
  String get safeRelocation;

  /// No description provided for @legalDocs.
  ///
  /// In en, this message translates to:
  /// **'Legal Docs'**
  String get legalDocs;

  /// No description provided for @verifiedLawyers.
  ///
  /// In en, this message translates to:
  /// **'Verified Lawyers'**
  String get verifiedLawyers;

  /// No description provided for @marketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace;

  /// No description provided for @materialsAndMore.
  ///
  /// In en, this message translates to:
  /// **'Materials & More'**
  String get materialsAndMore;

  /// No description provided for @serviceTracking.
  ///
  /// In en, this message translates to:
  /// **'Service Tracking'**
  String get serviceTracking;

  /// No description provided for @trackOrders.
  ///
  /// In en, this message translates to:
  /// **'Track Orders'**
  String get trackOrders;

  /// No description provided for @toolsAndSupport.
  ///
  /// In en, this message translates to:
  /// **'TOOLS & SUPPORT'**
  String get toolsAndSupport;

  /// No description provided for @emiCalculator.
  ///
  /// In en, this message translates to:
  /// **'EMI Calculator'**
  String get emiCalculator;

  /// No description provided for @planYourFinances.
  ///
  /// In en, this message translates to:
  /// **'Plan your finances'**
  String get planYourFinances;

  /// No description provided for @liveSupport.
  ///
  /// In en, this message translates to:
  /// **'Live Support'**
  String get liveSupport;

  /// No description provided for @chatWithExperts.
  ///
  /// In en, this message translates to:
  /// **'Chat with experts'**
  String get chatWithExperts;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED'**
  String get verified;

  /// No description provided for @goldStandardProtection.
  ///
  /// In en, this message translates to:
  /// **'Gold Standard Protection'**
  String get goldStandardProtection;

  /// No description provided for @strictlyVetted.
  ///
  /// In en, this message translates to:
  /// **'All service partners are strictly vetted.'**
  String get strictlyVetted;

  /// No description provided for @hot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get hot;

  /// No description provided for @noPropertiesYet.
  ///
  /// In en, this message translates to:
  /// **'No properties listed yet.'**
  String get noPropertiesYet;

  /// No description provided for @featuredZeroBrokerage.
  ///
  /// In en, this message translates to:
  /// **'FEATURED\nZERO-BROKERAGE'**
  String get featuredZeroBrokerage;

  /// No description provided for @newlyAdded.
  ///
  /// In en, this message translates to:
  /// **'NEWLY ADDED'**
  String get newlyAdded;

  /// No description provided for @savedProperties.
  ///
  /// In en, this message translates to:
  /// **'Saved Properties'**
  String get savedProperties;

  /// No description provided for @pleaseLoginToSeeSaved.
  ///
  /// In en, this message translates to:
  /// **'Please log in to see saved properties.'**
  String get pleaseLoginToSeeSaved;

  /// No description provided for @noSavedYet.
  ///
  /// In en, this message translates to:
  /// **'You have no saved properties yet.'**
  String get noSavedYet;

  /// No description provided for @pleaseLoginToViewMessages.
  ///
  /// In en, this message translates to:
  /// **'Please login to view messages.'**
  String get pleaseLoginToViewMessages;

  /// No description provided for @noConversationsYet.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversationsYet;

  /// No description provided for @youLabel.
  ///
  /// In en, this message translates to:
  /// **'You: '**
  String get youLabel;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// No description provided for @propertiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get propertiesTitle;

  /// No description provided for @searchPropertiesHint.
  ///
  /// In en, this message translates to:
  /// **'Search by area or developer...'**
  String get searchPropertiesHint;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// No description provided for @rentLease.
  ///
  /// In en, this message translates to:
  /// **'Rent/Lease'**
  String get rentLease;

  /// No description provided for @featuredCollections.
  ///
  /// In en, this message translates to:
  /// **'Featured Collections'**
  String get featuredCollections;

  /// No description provided for @noPropertiesMatch.
  ///
  /// In en, this message translates to:
  /// **'No properties matches your filters.'**
  String get noPropertiesMatch;

  /// No description provided for @filterProperties.
  ///
  /// In en, this message translates to:
  /// **'Filter Properties'**
  String get filterProperties;

  /// No description provided for @propertyType.
  ///
  /// In en, this message translates to:
  /// **'PROPERTY TYPE'**
  String get propertyType;

  /// No description provided for @bathroomsTitle.
  ///
  /// In en, this message translates to:
  /// **'BATHROOMS'**
  String get bathroomsTitle;

  /// No description provided for @builtYearLabel.
  ///
  /// In en, this message translates to:
  /// **'BUILT YEAR'**
  String get builtYearLabel;

  /// No description provided for @priceRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'PRICE RANGE (₹)'**
  String get priceRangeLabel;

  /// No description provided for @bedroomsLabel.
  ///
  /// In en, this message translates to:
  /// **'BEDROOMS'**
  String get bedroomsLabel;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @zeroBrokerageTag.
  ///
  /// In en, this message translates to:
  /// **'0 BROKERAGE'**
  String get zeroBrokerageTag;

  /// No description provided for @verifiedTag.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED'**
  String get verifiedTag;

  /// No description provided for @askingPrice.
  ///
  /// In en, this message translates to:
  /// **'ASKING PRICE'**
  String get askingPrice;

  /// No description provided for @listedBy.
  ///
  /// In en, this message translates to:
  /// **'LISTED BY'**
  String get listedBy;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @propertyDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Property Details'**
  String get propertyDetailsTitle;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION'**
  String get descriptionLabel;

  /// No description provided for @chatWithOwner.
  ///
  /// In en, this message translates to:
  /// **'Chat with Owner'**
  String get chatWithOwner;

  /// No description provided for @bed.
  ///
  /// In en, this message translates to:
  /// **'Bed'**
  String get bed;

  /// No description provided for @bath.
  ///
  /// In en, this message translates to:
  /// **'Bath'**
  String get bath;

  /// No description provided for @sqft.
  ///
  /// In en, this message translates to:
  /// **'sqft'**
  String get sqft;

  /// No description provided for @apartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get apartment;

  /// No description provided for @villa.
  ///
  /// In en, this message translates to:
  /// **'Villa'**
  String get villa;

  /// No description provided for @penthouse.
  ///
  /// In en, this message translates to:
  /// **'Penthouse'**
  String get penthouse;

  /// No description provided for @studio.
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get studio;

  /// No description provided for @listPropertyTitle.
  ///
  /// In en, this message translates to:
  /// **'List Your Property'**
  String get listPropertyTitle;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of 3'**
  String stepOf(int step);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @postListing.
  ///
  /// In en, this message translates to:
  /// **'Post Listing'**
  String get postListing;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInfo;

  /// No description provided for @propertyDetails.
  ///
  /// In en, this message translates to:
  /// **'Property Details'**
  String get propertyDetails;

  /// No description provided for @pricingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Pricing & Photos'**
  String get pricingPhotos;

  /// No description provided for @listingType.
  ///
  /// In en, this message translates to:
  /// **'Listing Type'**
  String get listingType;

  /// No description provided for @furnishingStatus.
  ///
  /// In en, this message translates to:
  /// **'Furnishing Status'**
  String get furnishingStatus;

  /// No description provided for @builtUpArea.
  ///
  /// In en, this message translates to:
  /// **'Built Up Area'**
  String get builtUpArea;

  /// No description provided for @yearBuilt.
  ///
  /// In en, this message translates to:
  /// **'Year Built'**
  String get yearBuilt;

  /// No description provided for @lotSize.
  ///
  /// In en, this message translates to:
  /// **'Lot Size'**
  String get lotSize;

  /// No description provided for @expectedPrice.
  ///
  /// In en, this message translates to:
  /// **'Expected Price (₹)'**
  String get expectedPrice;

  /// No description provided for @monthlyRent.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY RENT (₹)'**
  String get monthlyRent;

  /// No description provided for @securityDeposit.
  ///
  /// In en, this message translates to:
  /// **'Security Deposit (₹)'**
  String get securityDeposit;

  /// No description provided for @propertyDescription.
  ///
  /// In en, this message translates to:
  /// **'Property Description'**
  String get propertyDescription;

  /// No description provided for @bhkConfiguration.
  ///
  /// In en, this message translates to:
  /// **'BHK Configuration'**
  String get bhkConfiguration;

  /// No description provided for @uploadPhotos.
  ///
  /// In en, this message translates to:
  /// **'Upload Photos'**
  String get uploadPhotos;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get useCurrentLocation;

  /// No description provided for @fetchingLocation.
  ///
  /// In en, this message translates to:
  /// **'Fetching Location...'**
  String get fetchingLocation;

  /// No description provided for @locationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Location updated successfully!'**
  String get locationUpdated;

  /// No description provided for @couldNotFetchLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch location. Please check permissions.'**
  String get couldNotFetchLocation;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @houseVilla.
  ///
  /// In en, this message translates to:
  /// **'House/Villa'**
  String get houseVilla;

  /// No description provided for @plot.
  ///
  /// In en, this message translates to:
  /// **'Plot'**
  String get plot;

  /// No description provided for @pg.
  ///
  /// In en, this message translates to:
  /// **'PG'**
  String get pg;

  /// No description provided for @commercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get commercial;

  /// No description provided for @unfurnished.
  ///
  /// In en, this message translates to:
  /// **'Unfurnished'**
  String get unfurnished;

  /// No description provided for @semiFurnished.
  ///
  /// In en, this message translates to:
  /// **'Semi-Furnished'**
  String get semiFurnished;

  /// No description provided for @fullyFurnished.
  ///
  /// In en, this message translates to:
  /// **'Fully Furnished'**
  String get fullyFurnished;

  /// No description provided for @propertyNotFound.
  ///
  /// In en, this message translates to:
  /// **'Property not found'**
  String get propertyNotFound;

  /// No description provided for @pleaseLoginToSave.
  ///
  /// In en, this message translates to:
  /// **'Please log in to save properties'**
  String get pleaseLoginToSave;

  /// No description provided for @totalArea.
  ///
  /// In en, this message translates to:
  /// **'TOTAL AREA'**
  String get totalArea;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'OVERVIEW'**
  String get overview;

  /// No description provided for @amenities.
  ///
  /// In en, this message translates to:
  /// **'AMENITIES'**
  String get amenities;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description provided for this listing.'**
  String get noDescription;

  /// No description provided for @readFullSpec.
  ///
  /// In en, this message translates to:
  /// **'Read Full Specification'**
  String get readFullSpec;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'LOCATION'**
  String get locationLabel;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'GET DIRECTIONS'**
  String get getDirections;

  /// No description provided for @pleaseLoginToChat.
  ///
  /// In en, this message translates to:
  /// **'Please log in to chat with the owner'**
  String get pleaseLoginToChat;

  /// No description provided for @builtIn.
  ///
  /// In en, this message translates to:
  /// **'BUILT IN'**
  String get builtIn;

  /// No description provided for @bookVisit.
  ///
  /// In en, this message translates to:
  /// **'Book a Visit'**
  String get bookVisit;

  /// No description provided for @visitScheduled.
  ///
  /// In en, this message translates to:
  /// **'Visit Scheduled!'**
  String get visitScheduled;

  /// No description provided for @visitScheduledMsg.
  ///
  /// In en, this message translates to:
  /// **'Your visit for \"{title}\" has been requested for {date} at {time}. You can track this in the Tracking Hub.'**
  String visitScheduledMsg(String title, String date, String time);

  /// No description provided for @great.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get great;

  /// No description provided for @failedToSchedule.
  ///
  /// In en, this message translates to:
  /// **'Failed to schedule visit: {error}'**
  String failedToSchedule(String error);

  /// No description provided for @ownerLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get ownerLabel;

  /// No description provided for @noAmenities.
  ///
  /// In en, this message translates to:
  /// **'No amenities listed.'**
  String get noAmenities;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// No description provided for @loanAmount.
  ///
  /// In en, this message translates to:
  /// **'LOAN AMOUNT'**
  String get loanAmount;

  /// No description provided for @tenure.
  ///
  /// In en, this message translates to:
  /// **'TENURE'**
  String get tenure;

  /// No description provided for @interestRate.
  ///
  /// In en, this message translates to:
  /// **'INTEREST RATE'**
  String get interestRate;

  /// No description provided for @checkEligibility.
  ///
  /// In en, this message translates to:
  /// **'Check Eligibility'**
  String get checkEligibility;

  /// No description provided for @totalInterest.
  ///
  /// In en, this message translates to:
  /// **'TOTAL INTEREST'**
  String get totalInterest;

  /// No description provided for @totalPayable.
  ///
  /// In en, this message translates to:
  /// **'TOTAL PAYABLE'**
  String get totalPayable;

  /// No description provided for @estimatedMonthlyEmi.
  ///
  /// In en, this message translates to:
  /// **'ESTIMATED MONTHLY EMI'**
  String get estimatedMonthlyEmi;

  /// No description provided for @lowRate.
  ///
  /// In en, this message translates to:
  /// **'LOW RATE'**
  String get lowRate;

  /// No description provided for @viewRepaymentSchedule.
  ///
  /// In en, this message translates to:
  /// **'View Repayment Schedule'**
  String get viewRepaymentSchedule;

  /// No description provided for @buildingAndDesign.
  ///
  /// In en, this message translates to:
  /// **'Building & Design'**
  String get buildingAndDesign;

  /// No description provided for @constructionDetails.
  ///
  /// In en, this message translates to:
  /// **'Construction Details'**
  String get constructionDetails;

  /// No description provided for @plotSize.
  ///
  /// In en, this message translates to:
  /// **'PLOT SIZE (SQ. FT.)'**
  String get plotSize;

  /// No description provided for @constructionType.
  ///
  /// In en, this message translates to:
  /// **'TYPE OF CONSTRUCTION'**
  String get constructionType;

  /// No description provided for @documentUpload.
  ///
  /// In en, this message translates to:
  /// **'DOCUMENT UPLOAD'**
  String get documentUpload;

  /// No description provided for @uploadPlotMap.
  ///
  /// In en, this message translates to:
  /// **'Upload plot map and local approvals'**
  String get uploadPlotMap;

  /// No description provided for @architecture.
  ///
  /// In en, this message translates to:
  /// **'Architecture'**
  String get architecture;

  /// No description provided for @interiors.
  ///
  /// In en, this message translates to:
  /// **'Interiors'**
  String get interiors;

  /// No description provided for @consultation.
  ///
  /// In en, this message translates to:
  /// **'Consultation'**
  String get consultation;

  /// No description provided for @borewell.
  ///
  /// In en, this message translates to:
  /// **'Borewell'**
  String get borewell;

  /// No description provided for @requestQuote.
  ///
  /// In en, this message translates to:
  /// **'REQUEST QUOTE & TIMELINE'**
  String get requestQuote;

  /// No description provided for @packersAndMovers.
  ///
  /// In en, this message translates to:
  /// **'Packers & Movers'**
  String get packersAndMovers;

  /// No description provided for @pickupLocation.
  ///
  /// In en, this message translates to:
  /// **'PICKUP LOCATION'**
  String get pickupLocation;

  /// No description provided for @dropLocation.
  ///
  /// In en, this message translates to:
  /// **'DROP LOCATION'**
  String get dropLocation;

  /// No description provided for @transitRoute.
  ///
  /// In en, this message translates to:
  /// **'TRANSIT ROUTE'**
  String get transitRoute;

  /// No description provided for @propertySize.
  ///
  /// In en, this message translates to:
  /// **'PROPERTY SIZE'**
  String get propertySize;

  /// No description provided for @schedulePickup.
  ///
  /// In en, this message translates to:
  /// **'SCHEDULE PICKUP'**
  String get schedulePickup;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Book Movers'**
  String get confirmBooking;

  /// No description provided for @professionalPacking.
  ///
  /// In en, this message translates to:
  /// **'Professional Packing Service'**
  String get professionalPacking;

  /// No description provided for @legalHub.
  ///
  /// In en, this message translates to:
  /// **'Legal Hub'**
  String get legalHub;

  /// No description provided for @rentAgreement.
  ///
  /// In en, this message translates to:
  /// **'Rent Agreement'**
  String get rentAgreement;

  /// No description provided for @consultLawyer.
  ///
  /// In en, this message translates to:
  /// **'Consult Lawyer'**
  String get consultLawyer;

  /// No description provided for @propertyVerification.
  ///
  /// In en, this message translates to:
  /// **'Property Verification'**
  String get propertyVerification;

  /// No description provided for @legalDispute.
  ///
  /// In en, this message translates to:
  /// **'Legal Dispute'**
  String get legalDispute;

  /// No description provided for @propertyAudit.
  ///
  /// In en, this message translates to:
  /// **'Property Audit'**
  String get propertyAudit;

  /// No description provided for @cement.
  ///
  /// In en, this message translates to:
  /// **'Cement'**
  String get cement;

  /// No description provided for @steel.
  ///
  /// In en, this message translates to:
  /// **'Steel'**
  String get steel;

  /// No description provided for @bricks.
  ///
  /// In en, this message translates to:
  /// **'Bricks'**
  String get bricks;

  /// No description provided for @paint.
  ///
  /// In en, this message translates to:
  /// **'Paint'**
  String get paint;

  /// No description provided for @basics.
  ///
  /// In en, this message translates to:
  /// **'Basics'**
  String get basics;

  /// No description provided for @bulkOrders.
  ///
  /// In en, this message translates to:
  /// **'BULK ORDERS'**
  String get bulkOrders;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'VIEW CART'**
  String get viewCart;

  /// No description provided for @materials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materials;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @propertiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get propertiesLabel;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @homeLoanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan your property investment with our hyper-precise financial engine.'**
  String get homeLoanSubtitle;

  /// No description provided for @yearsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 YEAR} other{{count} YEARS}}'**
  String yearsCount(num count);

  /// No description provided for @yrLabel.
  ///
  /// In en, this message translates to:
  /// **'1 YR'**
  String get yrLabel;

  /// No description provided for @yrsLabel.
  ///
  /// In en, this message translates to:
  /// **'30 YRS'**
  String get yrsLabel;

  /// No description provided for @termsApply.
  ///
  /// In en, this message translates to:
  /// **'SUBJECT TO TERMS AND CONDITIONS. POWERED BY SAMPATTI FINANCE.'**
  String get termsApply;

  /// No description provided for @civilEngineersQuality.
  ///
  /// In en, this message translates to:
  /// **'Verified civil engineers only. No open contractor pool to ensure extreme quality control.'**
  String get civilEngineersQuality;

  /// No description provided for @exactLocation.
  ///
  /// In en, this message translates to:
  /// **'EXACT LOCATION'**
  String get exactLocation;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'City, Neighborhood or Coordinates'**
  String get locationHint;

  /// No description provided for @budgetLabel.
  ///
  /// In en, this message translates to:
  /// **'BUDGET (₹)'**
  String get budgetLabel;

  /// No description provided for @budgetHint.
  ///
  /// In en, this message translates to:
  /// **'Estimated amount'**
  String get budgetHint;

  /// No description provided for @timelineLabel.
  ///
  /// In en, this message translates to:
  /// **'TIMELINE'**
  String get timelineLabel;

  /// No description provided for @timelineHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 6 Months'**
  String get timelineHint;

  /// No description provided for @constructionTypeHint.
  ///
  /// In en, this message translates to:
  /// **'House, Building, Duplex, etc.'**
  String get constructionTypeHint;

  /// No description provided for @architecturalDesign.
  ///
  /// In en, this message translates to:
  /// **'Architectural Design'**
  String get architecturalDesign;

  /// No description provided for @archSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Map planning and structural design by licensed architects.'**
  String get archSubtitle;

  /// No description provided for @plotDimensions.
  ///
  /// In en, this message translates to:
  /// **'PLOT DIMENSIONS'**
  String get plotDimensions;

  /// No description provided for @dimensionsHint.
  ///
  /// In en, this message translates to:
  /// **'L x W (in ft)'**
  String get dimensionsHint;

  /// No description provided for @facingLabel.
  ///
  /// In en, this message translates to:
  /// **'FACING'**
  String get facingLabel;

  /// No description provided for @facingHint.
  ///
  /// In en, this message translates to:
  /// **'North, East, etc.'**
  String get facingHint;

  /// No description provided for @floorsCount.
  ///
  /// In en, this message translates to:
  /// **'NO. OF FLOORS'**
  String get floorsCount;

  /// No description provided for @floorsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., G+2'**
  String get floorsHint;

  /// No description provided for @roomRequirement.
  ///
  /// In en, this message translates to:
  /// **'ROOM REQUIREMENT'**
  String get roomRequirement;

  /// No description provided for @roomsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 4 BHK'**
  String get roomsHint;

  /// No description provided for @parkingCapacity.
  ///
  /// In en, this message translates to:
  /// **'PARKING CAPACITY'**
  String get parkingCapacity;

  /// No description provided for @parkingHint.
  ///
  /// In en, this message translates to:
  /// **'No. of Cars / Bikes'**
  String get parkingHint;

  /// No description provided for @specialNeeds.
  ///
  /// In en, this message translates to:
  /// **'SPECIAL NEEDS (OPTIONAL)'**
  String get specialNeeds;

  /// No description provided for @specialNeedsHint.
  ///
  /// In en, this message translates to:
  /// **'Vastu compliance, Garden, Pool, etc.'**
  String get specialNeedsHint;

  /// No description provided for @outputRequired.
  ///
  /// In en, this message translates to:
  /// **'OUTPUT REQUIRED'**
  String get outputRequired;

  /// No description provided for @conceptualPlan.
  ///
  /// In en, this message translates to:
  /// **'Conceptual Plan (MVP)'**
  String get conceptualPlan;

  /// No description provided for @structuralPlan.
  ///
  /// In en, this message translates to:
  /// **'Structural Plan'**
  String get structuralPlan;

  /// No description provided for @threeDElevation.
  ///
  /// In en, this message translates to:
  /// **'3D Elevation (Phase 2)'**
  String get threeDElevation;

  /// No description provided for @interiorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Transform spaces with our curated interior design partners.'**
  String get interiorSubtitle;

  /// No description provided for @propertyTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Apartment, Villa'**
  String get propertyTypeHint;

  /// No description provided for @bhkRooms.
  ///
  /// In en, this message translates to:
  /// **'BHK / ROOMS'**
  String get bhkRooms;

  /// No description provided for @carpetArea.
  ///
  /// In en, this message translates to:
  /// **'CARPET AREA'**
  String get carpetArea;

  /// No description provided for @sqFtHint.
  ///
  /// In en, this message translates to:
  /// **'In Sq. Ft.'**
  String get sqFtHint;

  /// No description provided for @stylePreference.
  ///
  /// In en, this message translates to:
  /// **'STYLE PREFERENCE'**
  String get stylePreference;

  /// No description provided for @modernMinimalist.
  ///
  /// In en, this message translates to:
  /// **'Modern Minimalist'**
  String get modernMinimalist;

  /// No description provided for @traditionalIndian.
  ///
  /// In en, this message translates to:
  /// **'Traditional Indian'**
  String get traditionalIndian;

  /// No description provided for @contemporary.
  ///
  /// In en, this message translates to:
  /// **'Contemporary'**
  String get contemporary;

  /// No description provided for @industrial.
  ///
  /// In en, this message translates to:
  /// **'Industrial'**
  String get industrial;

  /// No description provided for @luxury.
  ///
  /// In en, this message translates to:
  /// **'Luxury'**
  String get luxury;

  /// No description provided for @scopeSelection.
  ///
  /// In en, this message translates to:
  /// **'SCOPE SELECTION'**
  String get scopeSelection;

  /// No description provided for @fullHomeInterior.
  ///
  /// In en, this message translates to:
  /// **'Full Home Interior'**
  String get fullHomeInterior;

  /// No description provided for @modularKitchen.
  ///
  /// In en, this message translates to:
  /// **'Modular Kitchen'**
  String get modularKitchen;

  /// No description provided for @wardrobesStorage.
  ///
  /// In en, this message translates to:
  /// **'Wardrobes & Storage'**
  String get wardrobesStorage;

  /// No description provided for @roomRenovation.
  ///
  /// In en, this message translates to:
  /// **'Room-Specific Renovation'**
  String get roomRenovation;

  /// No description provided for @expertConsultation.
  ///
  /// In en, this message translates to:
  /// **'Expert Consultation'**
  String get expertConsultation;

  /// No description provided for @consultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Civil-engineer-led consultation to inspect or advise on building matters.'**
  String get consultSubtitle;

  /// No description provided for @consultationTopic.
  ///
  /// In en, this message translates to:
  /// **'CONSULTATION TOPIC'**
  String get consultationTopic;

  /// No description provided for @consultTopicHint.
  ///
  /// In en, this message translates to:
  /// **'Structural Audit, Material Quality, Seepage, etc.'**
  String get consultTopicHint;

  /// No description provided for @propertyAddress.
  ///
  /// In en, this message translates to:
  /// **'PROPERTY ADDRESS'**
  String get propertyAddress;

  /// No description provided for @propertyAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Where is the property?'**
  String get propertyAddressHint;

  /// No description provided for @detailedQuery.
  ///
  /// In en, this message translates to:
  /// **'DETAILED QUERY'**
  String get detailedQuery;

  /// No description provided for @queryHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue or advice needed...'**
  String get queryHint;

  /// No description provided for @verifiedExpertsOnly.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED EXPERTS ONLY'**
  String get verifiedExpertsOnly;

  /// No description provided for @expertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your lead is routed smartly and securely.'**
  String get expertsSubtitle;

  /// No description provided for @boringBorewell.
  ///
  /// In en, this message translates to:
  /// **'Boring & Borewell'**
  String get boringBorewell;

  /// No description provided for @borewellSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Expert surveying and drilling tailored to geographical constraints.'**
  String get borewellSubtitle;

  /// No description provided for @exactLocationBorewell.
  ///
  /// In en, this message translates to:
  /// **'EXACT LOCATION / PLOT NO.'**
  String get exactLocationBorewell;

  /// No description provided for @landmarkHint.
  ///
  /// In en, this message translates to:
  /// **'Enter landmark'**
  String get landmarkHint;

  /// No description provided for @soilType.
  ///
  /// In en, this message translates to:
  /// **'TYPE OF SOIL (IF KNOWN)'**
  String get soilType;

  /// No description provided for @soilTypeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Rocky, Red'**
  String get soilTypeHint;

  /// No description provided for @expectedDepth.
  ///
  /// In en, this message translates to:
  /// **'EXPECTED DEPTH'**
  String get expectedDepth;

  /// No description provided for @depthHint.
  ///
  /// In en, this message translates to:
  /// **'In Feet'**
  String get depthHint;

  /// No description provided for @purposeLabel.
  ///
  /// In en, this message translates to:
  /// **'PURPOSE'**
  String get purposeLabel;

  /// No description provided for @residentialWater.
  ///
  /// In en, this message translates to:
  /// **'Residential Water Supply'**
  String get residentialWater;

  /// No description provided for @agricultureFarming.
  ///
  /// In en, this message translates to:
  /// **'Agriculture / Farming'**
  String get agricultureFarming;

  /// No description provided for @industrialSupply.
  ///
  /// In en, this message translates to:
  /// **'Industrial Supply'**
  String get industrialSupply;

  /// No description provided for @requestSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request Sent! A verified professional will contact you soon.'**
  String get requestSentSuccess;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get loginError;

  /// No description provided for @tapToUpload.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload files'**
  String get tapToUpload;

  /// No description provided for @searchDestination.
  ///
  /// In en, this message translates to:
  /// **'Search destination...'**
  String get searchDestination;

  /// No description provided for @shiftingTimeDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Shifting time depends on distance and inventory volume.'**
  String get shiftingTimeDisclaimer;

  /// No description provided for @enterDropLocation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a drop location.'**
  String get enterDropLocation;

  /// No description provided for @moversBookedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Movers Booked Successfully!'**
  String get moversBookedSuccess;

  /// No description provided for @moversArrivalMsg.
  ///
  /// In en, this message translates to:
  /// **'Our team will arrive at {address} on {date} at {time}.'**
  String moversArrivalMsg(String address, String date, String time);

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @bookingSummary.
  ///
  /// In en, this message translates to:
  /// **'Booking Summary'**
  String get bookingSummary;

  /// No description provided for @premiumCare.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM CARE'**
  String get premiumCare;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'INVENTORY'**
  String get inventory;

  /// No description provided for @packing.
  ///
  /// In en, this message translates to:
  /// **'PACKING'**
  String get packing;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'DISTANCE'**
  String get distance;

  /// No description provided for @insurance.
  ///
  /// In en, this message translates to:
  /// **'INSURANCE'**
  String get insurance;

  /// No description provided for @included.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get included;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @calculatedAtPickup.
  ///
  /// In en, this message translates to:
  /// **'Calculated at pickup'**
  String get calculatedAtPickup;

  /// No description provided for @standardInsurance.
  ///
  /// In en, this message translates to:
  /// **'Standard (+0)'**
  String get standardInsurance;

  /// No description provided for @estQuote.
  ///
  /// In en, this message translates to:
  /// **'Est. Quote'**
  String get estQuote;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'REVIEW'**
  String get review;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'VERIFY'**
  String get verify;

  /// No description provided for @sign.
  ///
  /// In en, this message translates to:
  /// **'SIGN'**
  String get sign;

  /// No description provided for @draftAgreement.
  ///
  /// In en, this message translates to:
  /// **'Draft Agreement'**
  String get draftAgreement;

  /// No description provided for @fillAgreementTerms.
  ///
  /// In en, this message translates to:
  /// **'Fill in the specific terms of the rental lease before verification.'**
  String get fillAgreementTerms;

  /// No description provided for @lessorName.
  ///
  /// In en, this message translates to:
  /// **'LESSOR (LANDLORD) NAME'**
  String get lessorName;

  /// No description provided for @lesseeName.
  ///
  /// In en, this message translates to:
  /// **'LESSEE (TENANT) NAME'**
  String get lesseeName;

  /// No description provided for @depositLabel.
  ///
  /// In en, this message translates to:
  /// **'DEPOSIT (₹)'**
  String get depositLabel;

  /// No description provided for @ekycVerification.
  ///
  /// In en, this message translates to:
  /// **'E-KYC Verification'**
  String get ekycVerification;

  /// No description provided for @verifyIdentitiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verify identities securely before stamping the document digitally.'**
  String get verifyIdentitiesSubtitle;

  /// No description provided for @landlordKyc.
  ///
  /// In en, this message translates to:
  /// **'Landlord KYC'**
  String get landlordKyc;

  /// No description provided for @tenantKyc.
  ///
  /// In en, this message translates to:
  /// **'Tenant KYC'**
  String get tenantKyc;

  /// No description provided for @leaseForProperty.
  ///
  /// In en, this message translates to:
  /// **'Residential Lease for Property ID: {id}'**
  String leaseForProperty(String id);

  /// No description provided for @digitalVerification.
  ///
  /// In en, this message translates to:
  /// **'DIGITAL VERIFICATION'**
  String get digitalVerification;

  /// No description provided for @estampedSeries.
  ///
  /// In en, this message translates to:
  /// **'E-STAMPED DOCUMENT • 2024 SERIES'**
  String get estampedSeries;

  /// No description provided for @lessorLabel.
  ///
  /// In en, this message translates to:
  /// **'LESSOR (LANDLORD)'**
  String get lessorLabel;

  /// No description provided for @lesseeLabel.
  ///
  /// In en, this message translates to:
  /// **'LESSEE (TENANT)'**
  String get lesseeLabel;

  /// No description provided for @premisesTerm.
  ///
  /// In en, this message translates to:
  /// **'PREMISES & TERM'**
  String get premisesTerm;

  /// No description provided for @monthlyRentClause.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY RENT'**
  String get monthlyRentClause;

  /// No description provided for @securityDepositClause.
  ///
  /// In en, this message translates to:
  /// **'SECURITY DEPOSIT'**
  String get securityDepositClause;

  /// No description provided for @noticePeriod.
  ///
  /// In en, this message translates to:
  /// **'NOTICE PERIOD'**
  String get noticePeriod;

  /// No description provided for @legalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This document is digitally prepared by Sampatti Bazar Legal. By signing, you agree to the Terms of Service and digital e-stamp protocols.'**
  String get legalDisclaimer;

  /// No description provided for @viewDocumentDetails.
  ///
  /// In en, this message translates to:
  /// **'View Full Document Details'**
  String get viewDocumentDetails;

  /// No description provided for @nextVerification.
  ///
  /// In en, this message translates to:
  /// **'Next: Verification'**
  String get nextVerification;

  /// No description provided for @generateAgreement.
  ///
  /// In en, this message translates to:
  /// **'Generate Agreement'**
  String get generateAgreement;

  /// No description provided for @signDocument.
  ///
  /// In en, this message translates to:
  /// **'Sign Document'**
  String get signDocument;

  /// No description provided for @submitConsultRequest.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT CONSULTATION REQUEST'**
  String get submitConsultRequest;

  /// No description provided for @requestFullVerification.
  ///
  /// In en, this message translates to:
  /// **'REQUEST FULL VERIFICATION'**
  String get requestFullVerification;

  /// No description provided for @legalCounsel.
  ///
  /// In en, this message translates to:
  /// **'Legal Counsel'**
  String get legalCounsel;

  /// No description provided for @legalCounselSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive trusted guidance from locally verified real-estate attorneys.'**
  String get legalCounselSubtitle;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'DISCLAIMER'**
  String get disclaimer;

  /// No description provided for @attorneyDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This form does not establish an attorney-client relationship. Information provided is not legal advice until a lawyer is officially retained.'**
  String get attorneyDisclaimer;

  /// No description provided for @cityRegion.
  ///
  /// In en, this message translates to:
  /// **'CITY / REGION'**
  String get cityRegion;

  /// No description provided for @propertyIdAny.
  ///
  /// In en, this message translates to:
  /// **'PROPERTY ID (IF ANY)'**
  String get propertyIdAny;

  /// No description provided for @legalRequirement.
  ///
  /// In en, this message translates to:
  /// **'LEGAL REQUIREMENT'**
  String get legalRequirement;

  /// No description provided for @propertyAuditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We thoroughly verify ownership history, title encumbrances, and structural clearances to keep you safe from fraud.'**
  String get propertyAuditSubtitle;

  /// No description provided for @verificationEnsures.
  ///
  /// In en, this message translates to:
  /// **'Verification ensures all local municipal NOCs and past ownership trails are legitimate.'**
  String get verificationEnsures;

  /// No description provided for @propertyIdOptional.
  ///
  /// In en, this message translates to:
  /// **'PROPERTY ID / RERA ID (OPTIONAL)'**
  String get propertyIdOptional;

  /// No description provided for @exactLocality.
  ///
  /// In en, this message translates to:
  /// **'EXACT LOCALITY OR PROJECT NAME'**
  String get exactLocality;

  /// No description provided for @typeOfAsset.
  ///
  /// In en, this message translates to:
  /// **'TYPE OF ASSET'**
  String get typeOfAsset;

  /// No description provided for @attachDocs.
  ///
  /// In en, this message translates to:
  /// **'Attach Documents for Verification'**
  String get attachDocs;

  /// No description provided for @attachDocsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sale deeds, NOCs, or previous agreements.'**
  String get attachDocsSubtitle;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get pending;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @buyingProperty.
  ///
  /// In en, this message translates to:
  /// **'Buying Property'**
  String get buyingProperty;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @villaRowHouse.
  ///
  /// In en, this message translates to:
  /// **'Villa / Row House'**
  String get villaRowHouse;

  /// No description provided for @commercialOffice.
  ///
  /// In en, this message translates to:
  /// **'Commercial Office'**
  String get commercialOffice;

  /// No description provided for @bulkOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Flat 15% off on construction steel'**
  String get bulkOrdersSubtitle;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found for this category.'**
  String get noProductsFound;

  /// No description provided for @viewCartLabel.
  ///
  /// In en, this message translates to:
  /// **'VIEW CART'**
  String get viewCartLabel;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'{title} added to cart!'**
  String addedToCart(Object title);

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get myCart;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Contact Name'**
  String get contactName;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @payOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Pay on Delivery / Credit Facility'**
  String get payOnDelivery;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @itemsTotal.
  ///
  /// In en, this message translates to:
  /// **'Items Total'**
  String get itemsTotal;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get deliveryFee;

  /// No description provided for @taxCharges.
  ///
  /// In en, this message translates to:
  /// **'Tax & Charges'**
  String get taxCharges;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// No description provided for @confirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get confirmOrder;

  /// No description provided for @orderSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order Placed Successfully!'**
  String get orderSuccess;

  /// No description provided for @orderSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your materials will be delivered soon.'**
  String get orderSuccessSubtitle;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get free;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @premiumMember.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM MEMBER'**
  String get premiumMember;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get account;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @myDocuments.
  ///
  /// In en, this message translates to:
  /// **'My Documents'**
  String get myDocuments;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferences;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @termsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy'**
  String get termsPrivacy;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'LOG OUT'**
  String get logOut;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdated;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get saveChanges;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get notifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @emailUpdates.
  ///
  /// In en, this message translates to:
  /// **'Email Updates'**
  String get emailUpdates;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'GENERAL'**
  String get general;

  /// No description provided for @locationServices.
  ///
  /// In en, this message translates to:
  /// **'Location Services'**
  String get locationServices;

  /// No description provided for @botWelcomeMsg.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Sampatti Bazar!\nI\'m your digital assistant.\nHow can I help you\nstreamline your real estate\njourney today?'**
  String get botWelcomeMsg;

  /// No description provided for @botErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'I\'m sorry, I\'m having bit of trouble connecting to our Sampatti systems. Please try again.'**
  String get botErrorMsg;

  /// No description provided for @botName.
  ///
  /// In en, this message translates to:
  /// **'Sampatti Bot'**
  String get botName;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get today;

  /// No description provided for @botIsThinking.
  ///
  /// In en, this message translates to:
  /// **'SAMPATTI BOT IS THINKING....'**
  String get botIsThinking;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'QUICK ACTIONS'**
  String get quickActions;

  /// No description provided for @trackMover.
  ///
  /// In en, this message translates to:
  /// **'Track Mover'**
  String get trackMover;

  /// No description provided for @scheduleVisit.
  ///
  /// In en, this message translates to:
  /// **'Schedule Visit'**
  String get scheduleVisit;

  /// No description provided for @askMeAnything.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything...'**
  String get askMeAnything;

  /// No description provided for @botPoweredBy.
  ///
  /// In en, this message translates to:
  /// **'Gemini Powered Intelligence • Secure Encryption'**
  String get botPoweredBy;

  /// No description provided for @loanExpert.
  ///
  /// In en, this message translates to:
  /// **'Loan / EMI Expert'**
  String get loanExpert;

  /// No description provided for @loanEligibilityForm.
  ///
  /// In en, this message translates to:
  /// **'Loan Eligibility Form'**
  String get loanEligibilityForm;

  /// No description provided for @employmentType.
  ///
  /// In en, this message translates to:
  /// **'EMPLOYMENT TYPE'**
  String get employmentType;

  /// No description provided for @salaried.
  ///
  /// In en, this message translates to:
  /// **'Salaried'**
  String get salaried;

  /// No description provided for @selfEmployed.
  ///
  /// In en, this message translates to:
  /// **'Self-Employed'**
  String get selfEmployed;

  /// No description provided for @annualIncome.
  ///
  /// In en, this message translates to:
  /// **'ANNUAL INCOME (₹)'**
  String get annualIncome;

  /// No description provided for @cibilScore.
  ///
  /// In en, this message translates to:
  /// **'CIBIL / CREDIT SCORE'**
  String get cibilScore;

  /// No description provided for @monthlyEmi.
  ///
  /// In en, this message translates to:
  /// **'EXISTING MONTHLY EMIs (₹)'**
  String get monthlyEmi;

  /// No description provided for @propertyValue.
  ///
  /// In en, this message translates to:
  /// **'PROPERTY VALUE (OPTIONAL)'**
  String get propertyValue;

  /// No description provided for @submitApplication.
  ///
  /// In en, this message translates to:
  /// **'Submit Application'**
  String get submitApplication;

  /// No description provided for @loanExpertDashboard.
  ///
  /// In en, this message translates to:
  /// **'Loan Expert Dashboard'**
  String get loanExpertDashboard;

  /// No description provided for @loanLeads.
  ///
  /// In en, this message translates to:
  /// **'Loan Leads'**
  String get loanLeads;

  /// No description provided for @noLeadsYet.
  ///
  /// In en, this message translates to:
  /// **'No leads available yet.'**
  String get noLeadsYet;

  /// No description provided for @applicationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Application Submitted!'**
  String get applicationSubmitted;

  /// No description provided for @applicationSubmittedDesc.
  ///
  /// In en, this message translates to:
  /// **'A Loan Expert will contact you shortly.'**
  String get applicationSubmittedDesc;

  /// No description provided for @packersMoversRole.
  ///
  /// In en, this message translates to:
  /// **'Packers & Movers Partner'**
  String get packersMoversRole;

  /// No description provided for @moversDashboard.
  ///
  /// In en, this message translates to:
  /// **'Movers Dashboard'**
  String get moversDashboard;

  /// No description provided for @approxDistance.
  ///
  /// In en, this message translates to:
  /// **'APPROX. DISTANCE (KM)'**
  String get approxDistance;

  /// No description provided for @providerQuote.
  ///
  /// In en, this message translates to:
  /// **'Provider Quote'**
  String get providerQuote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
