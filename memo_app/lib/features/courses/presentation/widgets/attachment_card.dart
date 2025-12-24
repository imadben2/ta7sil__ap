import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/lesson_attachment_entity.dart';

/// بطاقة عرض المرفق
class AttachmentCard extends StatelessWidget {
  final LessonAttachmentEntity attachment;
  final VoidCallback? onPreview;
  final VoidCallback? onDownload;

  const AttachmentCard({
    super.key,
    required this.attachment,
    this.onPreview,
    this.onDownload,
  });

  // Colors - Using AppColors for consistency
  static const _primaryPurple = AppColors.primary;
  static const _textPrimary = AppColors.slate900;
  static const _textSecondary = AppColors.slate600;
  static const _textMuted = AppColors.slate500;
  static const _borderColor = AppColors.borderLight;
  static const _bgColor = AppColors.slateBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          // File type icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getFileColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: _buildFileIcon(),
            ),
          ),
          const SizedBox(width: 12),
          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.fileNameAr,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      attachment.fileType.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getFileColor(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      attachment.formattedFileSize,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action buttons
          if (_canPreview()) ...[
            _buildActionButton(
              icon: Icons.visibility_rounded,
              onTap: onPreview,
              tooltip: 'معاينة',
            ),
            const SizedBox(width: 8),
          ],
          _buildActionButton(
            icon: Icons.download_rounded,
            onTap: onDownload,
            tooltip: 'تحميل',
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFileIcon() {
    IconData iconData;
    switch (attachment.fileType.toLowerCase()) {
      case 'pdf':
        iconData = Icons.picture_as_pdf_rounded;
        break;
      case 'doc':
      case 'docx':
        iconData = Icons.description_rounded;
        break;
      case 'ppt':
      case 'pptx':
        iconData = Icons.slideshow_rounded;
        break;
      case 'xls':
      case 'xlsx':
        iconData = Icons.table_chart_rounded;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        iconData = Icons.image_rounded;
        break;
      case 'zip':
      case 'rar':
        iconData = Icons.folder_zip_rounded;
        break;
      default:
        iconData = Icons.insert_drive_file_rounded;
    }

    return Icon(
      iconData,
      size: 24,
      color: _getFileColor(),
    );
  }

  Color _getFileColor() {
    switch (attachment.fileType.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFDC2626); // Red
      case 'doc':
      case 'docx':
        return const Color(0xFF2563EB); // Blue
      case 'ppt':
      case 'pptx':
        return const Color(0xFFEA580C); // Orange
      case 'xls':
      case 'xlsx':
        return const Color(0xFF16A34A); // Green
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return const Color(0xFF7C3AED); // Purple
      case 'zip':
      case 'rar':
        return const Color(0xFFF59E0B); // Yellow
      default:
        return _textSecondary;
    }
  }

  bool _canPreview() {
    // Can preview PDFs and images
    return attachment.isPdf || attachment.isImage;
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onTap,
    required String tooltip,
    bool isPrimary = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isPrimary ? _primaryPurple.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isPrimary ? _primaryPurple.withValues(alpha: 0.3) : _borderColor,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isPrimary ? _primaryPurple : _textSecondary,
          ),
        ),
      ),
    );
  }
}

/// قائمة المرفقات
class AttachmentsList extends StatelessWidget {
  final List<LessonAttachmentEntity> attachments;
  final Function(LessonAttachmentEntity)? onPreview;
  final Function(LessonAttachmentEntity)? onDownload;

  const AttachmentsList({
    super.key,
    required this.attachments,
    this.onPreview,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: attachments.map((attachment) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AttachmentCard(
          attachment: attachment,
          onPreview: onPreview != null ? () => onPreview!(attachment) : null,
          onDownload: onDownload != null ? () => onDownload!(attachment) : null,
        ),
      )).toList(),
    );
  }
}
