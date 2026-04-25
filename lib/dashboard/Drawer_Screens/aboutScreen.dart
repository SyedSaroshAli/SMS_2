/* import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/about_controller.dart';

class AboutScreen extends StatelessWidget {
  AboutScreen({Key? key}) : super(key: key);

  final AboutController controller = Get.put(AboutController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("About"),
        centerTitle: true,
        elevation: 0,
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.aboutData.value;

        if (data == null) {
          return const Center(child: Text("No Data Found"));
        }

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [

                const SizedBox(height: 12),

                // 🔷 HEADER CARD (UPDATED)
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 10 : 12),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmall ? 10 : 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [

                        // 🔷 RECTANGLE LOGO (FIXED)
                        Container(
                          width: isSmall ? 80 : 100,
                          height: isSmall ? 70 : 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(data.entityLogo),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // 🔷 NAME + SLOGAN
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.entityDesc,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmall ? 18 : 22,
                                  color: Colors.black, // ✅ BLACK
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                data.aboutDesc4,
                                style: TextStyle(
                                  fontSize: isSmall ? 12 : 14,
                                  color: Colors.red, // ✅ RED
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 🔷 ABOUT SECTION
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 10 : 12),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmall ? 10 : 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "About Us",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmall ? 16 : 18,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text(
                          data.aboutDesc1,
                          style: const TextStyle(height: 1.5),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          data.aboutDesc2,
                          style: const TextStyle(height: 1.5),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          data.aboutDesc3,
                          style: const TextStyle(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 🔷 CONTACT SECTION
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 10 : 12),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmall ? 10 : 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          "Contact",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmall ? 16 : 18,
                          ),
                        ),

                        const SizedBox(height: 12),

                        _textRow(
                          title: "Address:",
                          subtitle:
                              "${data.address1}\n${data.address2}",
                          icon: Icons.location_on,
                          isSmall: isSmall,
                        ),

                        const SizedBox(height: 10),

                        _textRow(
                          title: "Phone:",
                          subtitle: data.contact1,
                          icon: Icons.phone,
                          isSmall: isSmall,
                        ),

                        const SizedBox(height: 8),

                        _textRow(
                          title: "Phone:",
                          subtitle: data.contact2,
                          icon: Icons.phone,
                          isSmall: isSmall,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// 🔹 TEXT ROW
class _textRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSmall;

  const _textRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: isSmall ? 16 : 18,
          color: Colors.blue,
        ),
        const SizedBox(width: 8),

        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: isSmall ? 12 : 14,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: "$title ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: subtitle),
              ],
            ),
          ),
        ),
      ],
    );
  }
} */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:school_management_system/controllers/about_controller.dart';

import 'package:school_management_system/utils/app_footer.dart';

class AboutScreen extends StatelessWidget {
  AboutScreen({Key? key}) : super(key: key);

  final AboutController controller = Get.find<AboutController>();

  void _retry() {
    controller.fetchAboutData();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("About"),
        centerTitle: true,
        elevation: 0,
      ),
      bottomNavigationBar: const AppFooter(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.aboutData.value;

        if (data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Failed to load data",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _retry,
                  child: const Text("Retry"),
                )
              ],
            ),
          );
        }

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => _retry(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // 🔷 HEADER CARD
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: isSmall ? 10 : 12),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isSmall ? 10 : 14),
                      decoration: BoxDecoration(
                        color: theme.cardColor, // FIXED
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: data.entityLogo ?? "",
                              width: isSmall ? 80 : 100,
                              height: isSmall ? 70 : 80,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Container(
                                color: theme.dividerColor.withOpacity(0.2),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: theme.dividerColor.withOpacity(0.2),
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: theme.iconTheme.color,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.entityDesc ?? "",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmall ? 18 : 22,
                                    color: theme.textTheme.titleLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  data.aboutDesc4 ?? "",
                                  style: TextStyle(
                                    fontSize: isSmall ? 12 : 14,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 🔷 ABOUT SECTION
                  _buildCard(
                    context,
                    isSmall,
                    title: "About Us",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.aboutDesc1 ?? "",
                          style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.aboutDesc2 ?? "",
                          style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.aboutDesc3 ?? "",
                          style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 🔷 CONTACT SECTION
                  _buildCard(
                    context,
                    isSmall,
                    title: "Contact",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _textRow(
                          icon: Icons.location_on,
                          title: "Address:",
                          subtitle:
                              "${data.address1 ?? ""}\n${data.address2 ?? ""}",
                          isSmall: isSmall,
                        ),
                        const SizedBox(height: 10),
                        _textRow(
                          icon: Icons.phone,
                          title: "Phone:",
                          subtitle: data.contact1 ?? "",
                          isSmall: isSmall,
                        ),
                        const SizedBox(height: 8),
                        _textRow(
                          icon: Icons.phone,
                          title: "Phone:",
                          subtitle: data.contact2 ?? "",
                          isSmall: isSmall,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // 🔹 REUSABLE CARD (DARK MODE FIXED)
  Widget _buildCard(BuildContext context, bool isSmall,
      {required String title, required Widget child}) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 10 : 12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isSmall ? 10 : 14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmall ? 16 : 18,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

// 🔹 TEXT ROW (DARK MODE FIXED)
class _textRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSmall;

  const _textRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: isSmall ? 16 : 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "$title $subtitle",
            style: TextStyle(
              fontSize: isSmall ? 12 : 14,
              height: 1.4,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ],
    );
  }
}