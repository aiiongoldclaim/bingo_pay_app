import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/theme_colors.dart';

class ServiceLocationMap extends StatefulWidget {
  final String? latitude;
  final String? longitude;
  final String? address;
  final String serviceName;

  const ServiceLocationMap({
    super.key,
    this.latitude,
    this.longitude,
    this.address,
    required this.serviceName,
  });

  @override
  State<ServiceLocationMap> createState() => _ServiceLocationMapState();
}

class _ServiceLocationMapState extends State<ServiceLocationMap> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeMarker();
  }

  void _initializeMarker() {
    if (widget.latitude != null && widget.longitude != null) {
      try {
        final lat = double.parse(widget.latitude!);
        final lng = double.parse(widget.longitude!);

        if (lat.isNaN || lat.isInfinite || lng.isNaN || lng.isInfinite) {
          debugPrint('Invalid coordinates: lat=$lat, lng=$lng');
          return;
        }

        if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
          debugPrint('Coordinates out of range: lat=$lat, lng=$lng');
          return;
        }

        _markers = {
          Marker(
            markerId: const MarkerId('service_location'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: widget.serviceName,
              snippet: widget.address ?? 'Service Location',
            ),
            onTap: () {
              if (_mapController != null && mounted) {
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(LatLng(lat, lng), 18),
                );
              }
            },
          ),
        };
      } catch (e) {
        debugPrint('Error parsing coordinates: $e');
        _markers = {};
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    if (mounted) {
      _mapController = controller;
      if (widget.latitude != null && widget.longitude != null) {
        try {
          final lat = double.parse(widget.latitude!);
          final lng = double.parse(widget.longitude!);

          if (lat.isNaN || lat.isInfinite || lng.isNaN || lng.isInfinite) {
            debugPrint('Invalid coordinates for camera animation: lat=$lat, lng=$lng');
            return;
          }

          if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
            debugPrint('Coordinates out of range for camera animation: lat=$lat, lng=$lng');
            return;
          }

          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16),
          );
        } catch (e) {
          debugPrint('Error animating camera: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.latitude == null || widget.longitude == null) {
      return _buildNoLocationWidget();
    }

    try {
      final lat = double.parse(widget.latitude!);
      final lng = double.parse(widget.longitude!);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ThemeColors.blue.withValues(alpha: 0.2),
                        ThemeColors.blue.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: ThemeColors.blue,
                    size: 6.w,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Location',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: ThemeColors.black,
                        ),
                      ),
                      if (widget.address != null &&
                          widget.address!.isNotEmpty)
                        Text(
                          widget.address!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Interactive Map
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            height: 35.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  // Google Map
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(lat, lng),
                      zoom: 16,
                    ),
                    markers: _markers,
                    zoomControlsEnabled: true,
                    compassEnabled: true,
                    mapToolbarEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    mapType: MapType.normal,
                  ),

                  // Address Card at Bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(2.5.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.serviceName,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          if (widget.address != null &&
                              widget.address!.isNotEmpty) ...[
                            SizedBox(height: 0.5.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white,
                                  size: 3.5.w,
                                ),
                                SizedBox(width: 1.w),
                                Expanded(
                                  child: Text(
                                    widget.address!,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.white
                                          .withValues(alpha: 0.9),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Map Controls Container
                  Positioned(
                    top: 1.5.w,
                    right: 1.5.w,
                    child: Column(
                      children: [
                        // Open in Google Maps Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                await _openInGoogleMaps(lat, lng);
                              },
                              borderRadius:
                                  BorderRadius.circular(50),
                              child: Padding(
                                padding: EdgeInsets.all(2.w),
                                child: Icon(
                                  Icons.open_in_new_rounded,
                                  color: ThemeColors.blue,
                                  size: 5.w,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Info Box
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.blue.withValues(alpha: 0.08),
                  ThemeColors.blue.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeColors.blue.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: ThemeColors.blue,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Drag, zoom, and rotate the map. Tap the pin to open in Google Maps.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } catch (e) {
      return _buildNoLocationWidget();
    }
  }

  Widget _buildNoLocationWidget() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_off_rounded,
            color: Colors.orange,
            size: 5.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Not Available',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Service location details are not available',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.orange.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openInGoogleMaps(double lat, double lng) async {
    try {
      final String googleMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

      final Uri url = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open Google Maps')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error opening Google Maps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error opening Google Maps')),
        );
      }
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
