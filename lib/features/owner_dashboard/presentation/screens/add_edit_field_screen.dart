import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:field_time/core/constants/app_colors.dart';
import 'package:field_time/core/constants/app_typography.dart';
import 'package:field_time/core/services/image_picker_service.dart';
import 'package:field_time/core/widgets/app_image.dart';
import 'package:field_time/core/widgets/custom_text_field.dart';
import 'package:field_time/core/widgets/primary_button.dart';
import 'package:field_time/features/home/data/models/field_model.dart';
import 'package:field_time/features/owner_dashboard/data/repositories/owner_repository.dart';
import 'package:field_time/features/owner_dashboard/presentation/cubit/owner_dashboard_cubit.dart';

class AddEditFieldScreen extends StatelessWidget {
  final OwnerDashboardCubit? ownerDashboardCubit;
  final String? fieldId;

  const AddEditFieldScreen({super.key, this.ownerDashboardCubit, this.fieldId});

  @override
  Widget build(BuildContext context) {
    return _AddEditFieldView(ownerDashboardCubit: ownerDashboardCubit, fieldId: fieldId);
  }
}

class _AddEditFieldView extends StatefulWidget {
  final OwnerDashboardCubit? ownerDashboardCubit;
  final String? fieldId;

  const _AddEditFieldView({this.ownerDashboardCubit, this.fieldId});

  @override
  State<_AddEditFieldView> createState() => _AddEditFieldViewState();
}

class _AddEditFieldViewState extends State<_AddEditFieldView> {
  OwnerDashboardCubit get _cubit =>
      widget.ownerDashboardCubit ?? context.read<OwnerDashboardCubit>();

  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _areaController;
  late final TextEditingController _addressController;
  late final TextEditingController _priceController;
  late final TextEditingController _oldPriceController;
  late final TextEditingController _phoneController;
  final ImagePickerService _pickerService = ImagePickerService();

  String _selectedCity = 'القاهرة';
  String _selectedFieldType = 'خماسي';
  String _selectedGrassType = 'عشب صناعي';
  bool _isIndoor = false;
  bool _isLoading = false;

  final List<String> _cities = const [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الشرقية',
    'المنصورة',
  ];
  final List<String> _fieldTypes = const ['خماسي', 'سباعي', '11v11', 'صالات'];
  final List<String> _grassTypes = const ['عشب صناعي', 'ترتان', 'عشب طبيعي'];

  final List<String> _allFacilities = const [
    'إضاءة ليلية',
    'مواقف سيارات',
    'دورات مياه',
    'مقهى',
    'غرف تبديل ملابس',
    'تكييف هوائي',
    'مدرجات',
  ];

  final List<String> _selectedFacilities = [
    'إضاءة ليلية',
    'مواقف سيارات',
    'دورات مياه',
  ];
  final List<String> _images = [
    'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&q=80&w=800',
  ];

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _areaController = TextEditingController();
    _oldPriceController = TextEditingController();
    _phoneController = TextEditingController();
    _priceController = TextEditingController();
    _descController = TextEditingController();
    if (widget.fieldId != null) {
      _loadExistingField();
    }
  }

  void _loadExistingField() async {
    final fields = await OwnerRepository().getOwnerFields();
    final field = fields.firstWhere(
      (f) => f.id == widget.fieldId,
      orElse: () => fields.first,
    );

    setState(() {
      _nameController.text = field.name;
      _descController.text = field.description;
      _areaController.text = field.area;
      _addressController.text = field.address;
      _priceController.text = field.pricePerHour.toInt().toString();
      if (field.oldPrice != null) {
        _oldPriceController.text = field.oldPrice!.toInt().toString();
      }
      _phoneController.text = field.phone ?? '';
      _selectedCity = field.city;
      _selectedFieldType = field.fieldType;
      _selectedGrassType = field.grassType;
      _isIndoor = field.isIndoor;

      _selectedFacilities.clear();
      _selectedFacilities.addAll(field.facilities);

      _images.clear();
      if (field.images.isNotEmpty) {
        _images.addAll(field.images);
      } else {
        _images.add(field.mainImage);
      }
    });
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    _nameController.dispose();
    _descController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _oldPriceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromCamera() async {
    final path = await _pickerService.pickImageFromCamera();
    if (path != null) {
      setState(() => _images.add(path));
    }
  }

  Future<void> _pickImagesFromGallery() async {
    final paths = await _pickerService.pickMultipleImagesFromGallery();
    if (paths.isNotEmpty) {
      setState(() => _images.addAll(paths));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final fieldModel = FieldModel(
      id: widget.fieldId ?? 'field-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      city: _selectedCity,
      area: _areaController.text.trim(),
      address: _addressController.text.trim(),
      pricePerHour: double.tryParse(_priceController.text.trim()) ?? 350.0,
      oldPrice: double.tryParse(_oldPriceController.text.trim()),
      rating: 4.8,
      reviewsCount: 12,
      distance: '1.5 كم',
      fieldType: _selectedFieldType,
      grassType: _selectedGrassType,
      isIndoor: _isIndoor,
      mainImage: _images.isNotEmpty
          ? _images.first
          : 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&q=80&w=800',
      images: _images,
      facilities: _selectedFacilities,
      isAvailableToday: true,
      phone: _phoneController.text.trim(),
    );

    if (widget.fieldId == null) {
      await _cubit.addField(fieldModel);
    } else {
      await _cubit.updateField(fieldModel);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.fieldId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'تعديل بيانات الملعب' : 'إضافة ملعب جديد',
          style: AppTypography.heading3(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 16.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Basic Info Section
                Text(
                  'المعلومات الأساسية',
                  style: AppTypography.title(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 14.h),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'اسم الملعب (مثال: أرينا سبورت)',
                  prefixIcon: const Icon(Icons.sports_soccer_outlined),
                  validator: (val) => val == null || val.isEmpty
                      ? 'يرجى إدخال اسم الملعب'
                      : null,
                ),
                SizedBox(height: 12.h),
                CustomTextField(
                  controller: _descController,
                  hintText: 'وصف الملعب والمميزات',
                  prefixIcon: const Icon(Icons.description_outlined),
                ),

                SizedBox(height: 24.h),

                // 2. Location & City Dropdown
                Text(
                  'الموقع والمدينة',
                  style: AppTypography.title(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 14.h),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCity,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark
                        ? AppColors.cardDark
                        : AppColors.greyLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.location_city_outlined),
                  ),
                  items: _cities.map((city) {
                    return DropdownMenuItem(value: city, child: Text(city));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCity = val!),
                ),
                SizedBox(height: 12.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _areaController,
                        hintText: 'المنطقة (مدينة نصر)',
                        prefixIcon: const Icon(Icons.map_outlined),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: CustomTextField(
                        controller: _phoneController,
                        hintText: 'رقم الهاتف',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                CustomTextField(
                  controller: _addressController,
                  hintText: 'العنوان التفصيلي (شارع الطيران...)',
                  prefixIcon: const Icon(Icons.place_outlined),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'يرجى إدخال العنوان' : null,
                ),

                SizedBox(height: 24.h),

                // 3. Price & Type Section
                Text(
                  'الأسعار ونوع الملعب',
                  style: AppTypography.title(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 14.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _priceController,
                        hintText: 'السعر / ساعة (ج.م)',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.attach_money_outlined),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'إلزامي' : null,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: CustomTextField(
                        controller: _oldPriceController,
                        hintText: 'السعر القديم (اختياري)',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.money_off_outlined),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),
                Text(
                  'نوع الملعب:',
                  style: AppTypography.caption(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  children: _fieldTypes.map((type) {
                    final isSelected = type == _selectedFieldType;
                    return ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                      ),
                      onSelected: (val) =>
                          setState(() => _selectedFieldType = type),
                    );
                  }).toList(),
                ),

                SizedBox(height: 14.h),
                Text(
                  'نوع الأرضية:',
                  style: AppTypography.caption(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  children: _grassTypes.map((grass) {
                    final isSelected = grass == _selectedGrassType;
                    return ChoiceChip(
                      label: Text(grass),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                      ),
                      onSelected: (val) =>
                          setState(() => _selectedGrassType = grass),
                    );
                  }).toList(),
                ),

                SizedBox(height: 14.h),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'هل الملعب مغطى / صالة؟',
                    style: AppTypography.body(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  value: _isIndoor,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isIndoor = val),
                ),

                SizedBox(height: 24.h),

                // 4. Facilities Multi-Select
                Text(
                  'المرافق والخدمات',
                  style: AppTypography.title(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _allFacilities.map((facility) {
                    final isSelected = _selectedFacilities.contains(facility);
                    return FilterChip(
                      label: Text(facility),
                      selected: isSelected,
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.primary,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedFacilities.add(facility);
                          } else {
                            _selectedFacilities.remove(facility);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                SizedBox(height: 24.h),

                // 5. Images List Manager
                Text(
                  'صور الملعب',
                  style: AppTypography.title(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickImageFromCamera,
                        icon: const Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          'الكاميرا',
                          style: AppTypography.caption(
                            color: AppColors.primary,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickImagesFromGallery,
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          color: Colors.white,
                        ),
                        label: Text(
                          'معرض الصور',
                          style: AppTypography.caption(
                            color: Colors.white,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                SizedBox(
                  height: 90.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 10.w),
                            width: 90.w,
                            height: 90.h,
                            child: AppImage(
                              imagePath: _images[index],
                              width: 90.w,
                              height: 90.h,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            left: 4,
                            child: GestureDetector(
                              onTap: () {
                                if (_images.length > 1) {
                                  setState(() => _images.removeAt(index));
                                }
                              },
                              child: CircleAvatar(
                                radius: 11.r,
                                backgroundColor: AppColors.error,
                                child: Icon(
                                  Icons.close,
                                  size: 13.sp,
                                  color: AppColors.backgroundLight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                SizedBox(height: 32.h),

                // 6. Submit Button
                PrimaryButton(
                  title: isEdit ? 'تحديث بيانات الملعب' : 'حفظ ونشر الملعب',
                  isLoading: _isLoading,
                  onPressed: _submitForm,
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
