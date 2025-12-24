<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateProfileRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => [
                'sometimes',
                'string',
                'email',
                'max:255',
                Rule::unique('users')->ignore($this->user()->id),
            ],
            'phone_number' => ['sometimes', 'nullable', 'string', 'max:20'],
            'bio' => ['sometimes', 'nullable', 'string', 'max:500'],
            'date_of_birth' => ['sometimes', 'nullable', 'date', 'before:today'],
            'gender' => ['sometimes', 'nullable', Rule::in(['male', 'female'])],
            'city' => ['sometimes', 'nullable', 'string', 'max:100'],
            'country' => ['sometimes', 'nullable', 'string', 'max:100'],
            'timezone' => ['sometimes', 'nullable', 'string', 'max:50'],
            'latitude' => ['sometimes', 'nullable', 'numeric', 'between:-90,90'],
            'longitude' => ['sometimes', 'nullable', 'numeric', 'between:-180,180'],
            'photo' => ['sometimes', 'nullable', 'image', 'mimes:jpeg,png,jpg', 'max:5120'], // 5MB max
        ];
    }

    /**
     * Get custom attributes for validator errors.
     *
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return [
            'name' => 'الاسم',
            'email' => 'البريد الإلكتروني',
            'phone_number' => 'رقم الهاتف',
            'bio' => 'السيرة الذاتية',
            'date_of_birth' => 'تاريخ الميلاد',
            'gender' => 'الجنس',
            'city' => 'المدينة',
            'country' => 'الدولة',
            'timezone' => 'المنطقة الزمنية',
            'photo' => 'الصورة الشخصية',
        ];
    }

    /**
     * Get custom messages for validator errors.
     *
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'photo.image' => 'يجب أن يكون الملف صورة',
            'photo.mimes' => 'يجب أن تكون الصورة من نوع: jpeg, png, jpg',
            'photo.max' => 'حجم الصورة يجب ألا يتجاوز 5 ميجابايت',
            'date_of_birth.before' => 'تاريخ الميلاد يجب أن يكون قبل اليوم',
        ];
    }
}
