import 'dart:ui';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/theme.dart';

import '../widgets/main_navigation.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_image_provider.dart';
import 'package:provider/provider.dart';
import 'orders_screen.dart';
import 'wishlist_screen.dart';
import 'addresses_screen.dart';
import 'settings_screen.dart';
import 'notification_screen.dart';
import 'edit_profile_screen.dart';


class ProfileScreen extends StatelessWidget {
  final bool isLoggedIn; // Set to false to show the Guest Screen by default

  const ProfileScreen({super.key, this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      drawer: const SettingsScreen(),
      appBar: _buildAppBar(context),
      body: isLoggedIn ? _buildLoggedInView(context) : _buildGuestView(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: NoorTheme.appBarBg(context),
      elevation: 0,
      centerTitle: true,
      title: Text(
        'NOOR FASHION',
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          color: NoorTheme.textColor(context),
        ),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, size: 24, color: NoorTheme.textColor(context)),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_none_outlined,
            color: NoorTheme.textColor(context),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildGuestImageLoading(BuildContext context) {
    return Container(
      color: NoorTheme.cardAlt(context),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: NoorTheme.textMuted(context),
          ),
        ),
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Stack(
      children: [
        // Background textures
        Positioned(
          top: -100,
          right: -50,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFED488).withValues(alpha: 0.15), // secondary-container approx
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFDCDAD5).withValues(alpha: 0.2), // surface-dim
              ),
            ),
          ),
        ),

        // Content Area
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hero Image Container with overlapping label
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.matrix(<double>[
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0,      0,      0,      1, 0,
                        ]),
                        child: Consumer<ProfileImageProvider>(
                          builder: (context, imageProvider, child) {
                            const guestDefaultImageUrl =
                                'https://res.cloudinary.com/dfodqj1wy/image/upload/v1779304269/static_21_fzha9h.png';

                            if (FirebaseAuth.instance.currentUser == null) {
                              return Image.network(
                                guestDefaultImageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return _buildGuestImageLoading(context);
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: NoorTheme.cardAlt(context),
                                    child: Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color: NoorTheme.textMuted(context),
                                        size: 48,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }

                            if (imageProvider.profileImageUrl != null && imageProvider.profileImageUrl!.isNotEmpty) {
                              final String url = imageProvider.profileImageUrl!;
                              if (url.startsWith('assets/')) {
                                return Image.asset(url, fit: BoxFit.cover);
                              } else if (url.startsWith('http')) {
                                return Image.network(url, fit: BoxFit.cover);
                              } else if (url.startsWith('data:image') || url.length > 500) {
                                String cleanBase64 = url;
                                if (cleanBase64.contains(',')) {
                                  cleanBase64 = cleanBase64.split(',').last;
                                }
                                return Image.memory(base64Decode(cleanBase64), fit: BoxFit.cover);
                              } else {
                                return Image.file(File(url), fit: BoxFit.cover);
                              }
                            }
                            return Image.network(
                              guestDefaultImageUrl,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -24,
                    right: -16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF775A19), // secondary
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Text(
                        'EST. MMXXIV',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.0, // approx 0.3em tracking
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),

              Text(
                'Guest.',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2.0,
                  color: NoorTheme.textColor(context),
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'JOIN THE ATELIER FOR A CURATED EXPERIENCE.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.0,
                    color: NoorTheme.textMuted(context), // on-surface-variant
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 48),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login', arguments: 2);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: NoorTheme.textColor(context),
                  foregroundColor: NoorTheme.isDark(context) ? NoorTheme.surfaceDark : Colors.white,
                  minimumSize: const Size(double.infinity, 56), // h-14
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                child: const Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register', arguments: 2);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: NoorTheme.textColor(context),
                  minimumSize: const Size(double.infinity, 56),
                  side: BorderSide(color: NoorTheme.textColor(context), width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text(
                  'REGISTER',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              TextButton(
                onPressed: () {},
                child: const Text(
                  'CONTINUE AS GUEST',
                  style: TextStyle(
                    color: Color(0xFF775A19), // secondary
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedInView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 48),
          _buildStatsGrid(context),
          const SizedBox(height: 40),
          _buildMenuActions(context),
          const SizedBox(height: 48),
          _buildLogoutButton(context),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Consumer2<ProfileProvider, ProfileImageProvider>(
      builder: (context, profileProvider, imageProvider, child) {
        final profile = profileProvider.profile;
        final user = FirebaseAuth.instance.currentUser;
        
        final name = profile?.fullName.isNotEmpty == true 
            ? profile!.fullName 
            : user?.displayName ?? 'Guest';
            
        final email = profile?.email.isNotEmpty == true 
            ? profile!.email 
            : user?.email ?? 'No email';
        
        // Determine the image to show
        ImageProvider avatarImage;
        if (imageProvider.imageBytes != null) {
          avatarImage = MemoryImage(imageProvider.imageBytes!);
        } else if (imageProvider.profileImageUrl != null && imageProvider.profileImageUrl!.isNotEmpty) {
          final String url = imageProvider.profileImageUrl!;
          if (url.startsWith('assets/')) {
            avatarImage = AssetImage(url);
          } else if (url.startsWith('http')) {
            avatarImage = NetworkImage(url);
          } else if (url.startsWith('data:image') || url.length > 500) {
            String cleanBase64 = url;
            if (cleanBase64.contains(',')) {
              cleanBase64 = cleanBase64.split(',').last;
            }
            avatarImage = MemoryImage(base64Decode(cleanBase64));
          } else {
            avatarImage = FileImage(File(url));
          }
        } else if (profile?.profileImageUrl.isNotEmpty == true) {
          final String url = profile!.profileImageUrl;
          if (url.startsWith('assets/')) {
            avatarImage = AssetImage(url);
          } else if (url.startsWith('http')) {
            avatarImage = NetworkImage(url);
          } else if (url.startsWith('data:image') || url.length > 500) {
            String cleanBase64 = url;
            if (cleanBase64.contains(',')) {
              cleanBase64 = cleanBase64.split(',').last;
            }
            avatarImage = MemoryImage(base64Decode(cleanBase64));
          } else {
            avatarImage = FileImage(File(url));
          }
        } else {
          avatarImage = const NetworkImage('https://res.cloudinary.com/dfodqj1wy/image/upload/v1779304269/static_21_fzha9h.png');
        }

        return Column(
          children: [
            GestureDetector(
              onTap: () => _showImagePickerBottomSheet(context, imageProvider),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFEBE8E3), width: 4),
                      image: DecorationImage(
                        image: avatarImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: imageProvider.isUploading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: NoorTheme.primaryNavy,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: NoorTheme.primaryNavy,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              name,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: NoorTheme.textColor(context),
              ),
            ),
            Text(
              email,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                color: NoorTheme.textMuted(context),
              ),
            ),
            if (imageProvider.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  imageProvider.error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      },
    );
  }

  void _showImagePickerBottomSheet(BuildContext context, ProfileImageProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Update Profile Picture',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: NoorTheme.primaryNavy,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: NoorTheme.primaryNavy),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await provider.pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: NoorTheme.primaryNavy),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await provider.pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder, color: NoorTheme.primaryNavy),
                title: const Text('Select a File'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await provider.pickFromFileManager();
                },
              ),
              ListTile(
                leading: const Icon(Icons.face, color: NoorTheme.primaryNavy),
                title: const Text('Choose Default Avatar'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showDefaultAvatarPicker(context, provider);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDefaultAvatarPicker(BuildContext context, ProfileImageProvider provider) {
    final List<String> avatars = [
      'https://res.cloudinary.com/dfodqj1wy/image/upload/v1779304269/static_21_fzha9h.png',
    ];

    showDialog(
      context: context,
      builder: (BuildContext bc) {
        return AlertDialog(
          title: const Text(
            'Select Avatar',
            style: TextStyle(
              color: NoorTheme.primaryNavy,
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: avatars.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                     // Need to update provider.setAssetProfileImage to handle Network Image correctly if selected. 
                     // Or just close for now since we only have one avatar
                    Navigator.of(context).pop();
                    // await provider.setAssetProfileImage(avatars[index]); 
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      avatars[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: NoorTheme.cardAlt(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: FirestoreService().getOrdersStream(FirebaseAuth.instance.currentUser!.uid),
                  builder: (context, snapshot) {
                    final orderCount = snapshot.data?.length ?? 0;
                    return Text(
                      '$orderCount',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: NoorTheme.textColor(context),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  'ORDERS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: NoorTheme.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: NoorTheme.cardAlt(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Gold',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF775A19),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'STATUS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: NoorTheme.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuActions(BuildContext context) {
    return Column(
      children: [
        _buildActionItem(
          context,
          'EDIT PROFILE',
          Icons.edit_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionItem(
          context,
          'MY ORDERS',
          Icons.inventory_2_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrdersScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionItem(context, 'SETTINGS', Icons.settings_outlined, onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        }),
        const SizedBox(height: 12),
        _buildActionItem(context, 'WISHLIST', Icons.favorite_border, onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WishlistScreen()),
          );
        }),
        const SizedBox(height: 12),
        _buildActionItem(context, 'ADDRESSES', Icons.location_on_outlined, onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddressesScreen()),
          );
        }),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, String title, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: NoorTheme.cardColor(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: NoorTheme.iconBg(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: NoorTheme.textColor(context), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: NoorTheme.textColor(context),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: NoorTheme.textMuted(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        try {
          await AuthService().signOut();
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const MainNavigation(
                  isLoggedIn: false,
                  initialIndex: 2, // Go straight back to Guest Profile to confirm logout visually
                ),
              ),
              (route) => false, // Clear history stack so they can't "back" into auth mode
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to log out: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: NoorTheme.textColor(context),
        foregroundColor: NoorTheme.isDark(context) ? NoorTheme.surfaceDark : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.logout, size: 20),
          SizedBox(width: 12),
          Text(
            'LOGOUT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}
