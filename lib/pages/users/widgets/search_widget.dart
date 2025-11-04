import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plumber_project/pages/users/controllers/user_dashboard_controller.dart';

class SearchWidget extends StatelessWidget {
  final HomeController controller;

  const SearchWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.showSearchBar.value
        ? Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller.searchController,
          autofocus: true,
          style: TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Search for services...",
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.search, color: Color(0xFF667eea)),
            suffixIcon: IconButton(
              icon: Icon(Icons.close, color: Colors.grey),
              onPressed: controller.toggleSearchBar,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
          onChanged: controller.filterServices,
        ),
      ),
    )
        : Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Available Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.search, color: Color(0xFF667eea)),
              onPressed: controller.toggleSearchBar,
              tooltip: 'Search Services',
            ),
          ),
        ],
      ),
    ));
  }
}