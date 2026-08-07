import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../domain/entities/service_entity.dart';

class ServiceDetailHeader extends StatefulWidget {
  final ServiceEntity service;

  const ServiceDetailHeader({
    super.key,
    required this.service,
  });

  @override
  State<ServiceDetailHeader> createState() => _ServiceDetailHeaderState();
}

class _ServiceDetailHeaderState extends State<ServiceDetailHeader> {

  final LatLng _center = const LatLng(28.6139, 77.2090); // Delhi
  late GoogleMapController _mapController;
  double _cardTop = 10;
  double _cardLeft = 0;

  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('delhi'),
      position: LatLng(28.6139, 77.2090),
      infoWindow: InfoWindow(title: 'Delhi'),
    ),
  };

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _updateCardPosition() async {
    if (!mounted) return;
    try {
      final markerPosition = LatLng(
        (widget.service.latitude?.isNotEmpty ?? false)
          ? double.parse(widget.service.latitude ?? "0.0")
          : 28.6139,
        (widget.service.longitude?.isNotEmpty ?? false)
          ? double.parse(widget.service.longitude ?? "0.0")
          : 77.2090,
      );

      final screenCoord = await _mapController.getScreenCoordinate(markerPosition);

      setState(() {
        _cardLeft = (screenCoord.x - 52).toDouble(); // Center the card (52 is half width)
        _cardTop = (screenCoord.y - 50).toDouble(); // Position above marker
      });
    } catch (e) {
      print('Error updating card position: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Service Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: widget.service.imageUrl.isNotEmpty
              ? Image.network(
                  widget.service.imageUrl,
                  height: 25.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 25.h,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported),
                  ),
                )
              : Container(
                  height: 25.h,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported),
                ),
        ),

        SizedBox(height: 2.h),

        // Title
        Text(
          widget.service.title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: ThemeColors.black,
          ),
        ),

        SizedBox(height: 1.h),

        // Vendor & Category
        Row(
          children: [
            Expanded(
              child: Text(
                widget.service.vendorName,
                style: TextStyle(
                  fontSize: 14.5.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 2.w,
                vertical: 0.5.h,
              ),
              decoration: BoxDecoration(
                color: ThemeColors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.service.categoryName,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  color: ThemeColors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 1.h),

        // Address
        if (widget.service.locationLabel != null && widget.service.locationLabel!.isNotEmpty)
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 14.sp,
                color: Colors.grey.shade600,
              ),
              SizedBox(width: 0.5.w),
              Expanded(
                child: Text(
                  widget.service.locationLabel!,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

        SizedBox(height: 1.5.h),

        // Rating & Reviews & Duration
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 17.sp,
                  color: Colors.amber,
                ),
                SizedBox(width: 0.5.w),
                Text(
                  '${widget.service.averageRating}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 0.5.w),
                Text(
                  '(${widget.service.totalReviews} reviews)',
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 16.sp,
                  color: ThemeColors.blue,
                ),
                SizedBox(width: 0.9.w),
                Text(
                  '${widget.service.durationMinutes}m',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w500,
                    color: ThemeColors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 1.5.h),

        Container(
        height: 25.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  (widget.service.latitude?.isNotEmpty ?? false) ? double.parse(widget.service.latitude ?? "0.0") : 28.6139,
                  (widget.service.longitude?.isNotEmpty ?? false) ? double.parse(widget.service.longitude ?? "0.0") : 77.2090),
                zoom: 12,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                Future.delayed(Duration(milliseconds: 500), _updateCardPosition);
              },
              onCameraMove: (_) => _updateCardPosition(),
              markers: {
                Marker(
                  markerId: MarkerId(widget.service.uuid),
                  position: LatLng(
                    (widget.service.latitude?.isNotEmpty ?? false) ? double.parse(widget.service.latitude ?? "0.0") : 28.6139,
                    (widget.service.longitude?.isNotEmpty ?? false) ? double.parse(widget.service.longitude ?? "0.0") : 77.2090),
                  infoWindow: InfoWindow(title: widget.service.title),
                ),
              },
            ),
            /// 🔥 Custom Info Card - Dynamically positioned at marker
      Positioned(
        top: _cardTop,
        left: _cardLeft,
        child: _customInfoCard(),
      ),
          ],
        ),
      ),

        SizedBox(height: 1.5.h),
      ],
    );
  }
  
Widget _customInfoCard() {
  return Material(
    elevation: 6,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: EdgeInsets.all(10),
      constraints: BoxConstraints(
        maxWidth: 220, // 🔥 CONTROL WIDTH HERE
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// TEXT
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.service.title ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "by ${widget.service.vendorName ?? ""}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),

          SizedBox(width: 8),

          /// IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.service.imageUrl ?? "",
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    ),
  );
}
}
