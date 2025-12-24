import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../../../core/utils/gradient_helper.dart';
import '../../../../core/utils/image_helper.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_event.dart';
import '../bloc/profile/profile_state.dart';
import '../widgets/profile_page_header.dart';

/// صفحة تعديل الملف الشخصي - تصميم عصري عربي
///
/// الحقول:
/// - صورة الملف الشخصي (crop/compress)
/// - الاسم الأول والأخير
/// - البريد الإلكتروني (readonly)
/// - رقم الهاتف (اختياري)
/// - السيرة الذاتية (bio)
/// - تاريخ الميلاد
/// - الجنس
/// - المدينة
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;

  String? _selectedGender;
  DateTime? _selectedDate;
  String _selectedCity = 'Algiers';

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
  }

  void _initializeFromProfile(ProfileState state) {
    if (_initialized) return;

    ProfileEntity? profile;
    if (state is ProfileLoaded) {
      profile = state.profile;
    } else if (state is ProfileUpdating) {
      profile = state.currentProfile;
    } else if (state is ProfilePhotoUploading) {
      profile = state.currentProfile;
    } else if (state is ProfilePhotoUploaded) {
      profile = state.profile;
    } else if (state is ProfileError && state.currentProfile != null) {
      profile = state.currentProfile;
    }

    if (profile != null) {
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone ?? '';
      _bioController.text = profile.bio ?? '';
      _selectedDate = profile.dateOfBirth;
      _selectedGender = profile.gender;
      _selectedCity = profile.city ?? 'Algiers';
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ التغييرات بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is ProfilePhotoUploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم رفع الصورة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        // Show loading indicator while fetching profile
        if (state is ProfileLoading || state is ProfileInitial) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: AppColors.slateBackground,
              body: Column(
                children: [
                  ProfilePageHeader(
                    title: 'تعديل الملف الشخصي',
                    subtitle: 'جاري تحميل البيانات...',
                    icon: Icons.edit_rounded,
                    onBack: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Initialize form fields from profile state
        _initializeFromProfile(state);

        // Check loading state
        final isUpdating = state is ProfileUpdating || state is ProfilePhotoUploading;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.slateBackground,
            body: Column(
              children: [
                // الهيدر الموحد
                ProfilePageHeader(
                  title: 'تعديل الملف الشخصي',
                  subtitle: 'تحديث بياناتك الشخصية',
                  icon: Icons.edit_rounded,
                  onBack: () => Navigator.pop(context),
                  onAction: isUpdating ? null : _handleSave,
                  actionIcon: Icons.check_rounded,
                ),
                // المحتوى
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // صورة الملف الشخصي
                        _buildProfilePhotoSection(state),

                        const SizedBox(height: 32),

                        // الاسم
                        _buildNameFields(),

                        const SizedBox(height: 20),

                        // البريد الإلكتروني (readonly)
                        _buildEmailField(),

                        const SizedBox(height: 20),

                        // رقم الهاتف
                        _buildPhoneField(),

                        const SizedBox(height: 20),

                        // السيرة الذاتية
                        _buildBioField(),

                        const SizedBox(height: 20),

                        // تاريخ الميلاد
                        _buildDateOfBirthField(),

                        const SizedBox(height: 20),

                        // الجنس
                        _buildGenderField(),

                        const SizedBox(height: 20),

                        // المدينة
                        _buildCityField(),

                        const SizedBox(height: 32),

                        // زر الحفظ
                        _buildSaveButton(isUpdating),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// قسم صورة الملف الشخصي
  Widget _buildProfilePhotoSection(ProfileState state) {
    // Get profile photo URL from state
    String? photoUrl;
    if (state is ProfileLoaded) {
      photoUrl = state.profile.avatar;
    } else if (state is ProfileUpdating) {
      photoUrl = state.currentProfile.avatar;
    } else if (state is ProfilePhotoUploading) {
      photoUrl = state.currentProfile.avatar;
    } else if (state is ProfilePhotoUploaded) {
      photoUrl = state.profile.avatar;
    } else if (state is ProfileError && state.currentProfile != null) {
      photoUrl = state.currentProfile!.avatar;
    }

    final isUploading = state is ProfilePhotoUploading;

    return Center(
      child: Stack(
        children: [
          // الصورة
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: GradientHelper.primary,
            ),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey[200],
                backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : const AssetImage('assets/images/avatar.png') as ImageProvider,
                child: isUploading
                    ? const CircularProgressIndicator()
                    : (photoUrl == null || photoUrl.isEmpty
                        ? Icon(Icons.person, size: 55, color: Colors.grey[400])
                        : null),
              ),
            ),
          ),

          // زر التعديل
          Positioned(
            bottom: 0,
            left: 90,
            child: GestureDetector(
              onTap: isUploading ? null : _showPhotoOptions,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUploading ? Colors.grey : AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowPrimary,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// حقول الاسم
  Widget _buildNameFields() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _firstNameController,
            label: 'الاسم الأول',
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'مطلوب';
              }
              if (value.length < 2) {
                return 'قصير جدًا';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTextField(
            controller: _lastNameController,
            label: 'اسم العائلة',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'مطلوب';
              }
              if (value.length < 2) {
                return 'قصير جدًا';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  /// حقل البريد الإلكتروني (readonly)
  Widget _buildEmailField() {
    return _buildTextField(
      controller: _emailController,
      label: 'البريد الإلكتروني',
      icon: Icons.email,
      enabled: false,
      suffixIcon: Icons.lock,
    );
  }

  /// حقل رقم الهاتف
  Widget _buildPhoneField() {
    return _buildTextField(
      controller: _phoneController,
      label: 'رقم الهاتف (اختياري)',
      icon: Icons.phone,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]'))],
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (!value.startsWith('+213')) {
            return 'يجب أن يبدأ بـ +213';
          }
        }
        return null;
      },
    );
  }

  /// حقل السيرة الذاتية
  Widget _buildBioField() {
    return _buildTextField(
      controller: _bioController,
      label: 'السيرة الذاتية (اختياري)',
      icon: Icons.info,
      maxLines: 3,
      maxLength: 150,
    );
  }

  /// حقل تاريخ الميلاد
  Widget _buildDateOfBirthField() {
    return GestureDetector(
      onTap: () => _selectDate(),
      child: Container(
        padding: EdgeInsets.all(AppDesignTokens.spacingLG),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calendar_today,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تاريخ الميلاد',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'اختر التاريخ',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// حقل الجنس
  Widget _buildGenderField() {
    return Container(
      padding: EdgeInsets.all(AppDesignTokens.spacingLG),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.wc, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                'الجنس',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildGenderOption('male', 'ذكر', Icons.male)),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGenderOption('female', 'أنثى', Icons.female),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// خيار جنس واحد
  Widget _buildGenderOption(String value, String label, IconData icon) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.grey[700],
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// حقل المدينة
  Widget _buildCityField() {
    final cities = ['Algiers', 'Oran', 'Constantine', 'Annaba', 'Batna'];
    final citiesAr = {
      'Algiers': 'الجزائر',
      'Oran': 'وهران',
      'Constantine': 'قسنطينة',
      'Annaba': 'عنابة',
      'Batna': 'باتنة',
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacingLG,
        vertical: AppDesignTokens.spacingSM,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.location_city,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: const InputDecoration(
                labelText: 'المدينة',
                border: InputBorder.none,
              ),
              items: cities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(
                    citiesAr[city] ?? city,
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCity = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  /// حقل نصي عام
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    IconData? suffixIcon,
    bool enabled = true,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      style: const TextStyle(fontFamily: 'Cairo'),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: Colors.grey, size: 20)
            : null,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }

  /// زر الحفظ
  Widget _buildSaveButton(bool isUpdating) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: isUpdating ? null : GradientHelper.primary,
        color: isUpdating ? Colors.grey : null,
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPrimary,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isUpdating ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          ),
        ),
        child: isUpdating
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'حفظ التغييرات',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSizeBody,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
      ),
    );
  }

  /// معالج الحفظ
  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    // Dispatch UpdateProfile event to bloc
    context.read<ProfileBloc>().add(UpdateProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      bio: _bioController.text.isNotEmpty ? _bioController.text : null,
      dateOfBirth: _selectedDate,
      gender: _selectedGender,
      city: _selectedCity,
    ));
  }

  /// اختيار تاريخ
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// خيارات الصورة
  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDesignTokens.borderRadiusCard),
        ),
      ),
      builder: (ctx) => Container(
        padding: EdgeInsets.all(AppDesignTokens.spacingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text(
                'التقاط صورة',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: AppColors.primary,
              ),
              title: const Text(
                'اختيار من المعرض',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'حذف الصورة',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              onTap: () {
                Navigator.pop(ctx);
                // TODO: Add delete photo functionality if needed
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Pick image from camera or gallery
  /// Pick, crop, and upload profile photo
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Use ImageHelper to pick, crop, and compress
      final File? imageFile = await ImageHelper.pickAndCropImage(
        context,
        source: source,
        maxSizeKB: 2048, // 2MB max
      );

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (imageFile == null) {
        // User cancelled
        return;
      }

      // Validate image
      final validationError = await ImageHelper.validateImage(imageFile);
      if (validationError != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                validationError,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // Show preview and confirmation dialog
      final confirmed = await _showPhotoPreview(imageFile);
      if (confirmed != true) {
        return;
      }

      // Dispatch upload photo event
      if (mounted) {
        context.read<ProfileBloc>().add(UploadProfilePhoto(imageFile));
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ: ${e.toString()}',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Show photo preview before upload
  Future<bool?> _showPhotoPreview(File imageFile) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'معاينة الصورة',
          style: TextStyle(fontFamily: 'Cairo'),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image preview
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                imageFile,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            // File size info
            FutureBuilder<int>(
              future: imageFile.length(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final sizeKB = (snapshot.data! / 1024).toStringAsFixed(0);
                  return Text(
                    'الحجم: $sizeKB KB',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'Cairo',
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text(
              'رفع الصورة',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }
}
