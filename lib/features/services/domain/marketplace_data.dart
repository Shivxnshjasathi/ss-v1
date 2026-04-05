import 'package:flutter/material.dart';

class MarketplaceCategory {
  final String id;
  final String name;
  final IconData icon;
  final List<String> subcategories;

  const MarketplaceCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.subcategories = const [],
  });
}

class MarketplaceProduct {
  final String id;
  final String categoryId;
  final String subcategory;
  final String name;
  final double price;
  final String unit;
  final String image;
  final String? brand;

  const MarketplaceProduct({
    required this.id,
    required this.categoryId,
    required this.subcategory,
    required this.name,
    required this.price,
    required this.unit,
    required this.image,
    this.brand,
  });
}

class MarketplaceData {
  static const List<MarketplaceCategory> categories = [
    MarketplaceCategory(
      id: 'masonry',
      name: 'Masonry & Structure',
      icon: Icons.foundation,
      subcategories: ['Bricks', 'Cement', 'Sand', 'Gitti', 'Murrum', 'Dust'],
    ),
    MarketplaceCategory(
      id: 'steel',
      name: 'Steel & Iron',
      icon: Icons.reorder,
      subcategories: ['TMT Rebar', 'Iron'],
    ),
    MarketplaceCategory(
      id: 'openings',
      name: 'Openings & Woodwork',
      icon: Icons.door_front_door,
      subcategories: ['Frames (Choukhaat)', 'Windows (Khidki)', 'Grills'],
    ),
    MarketplaceCategory(
      id: 'finishing',
      name: 'Finishing & Aesthetics',
      icon: Icons.brush,
      subcategories: ['Tiles & Stone', 'Paint & Prep', 'Ceiling', 'Wallpapers'],
    ),
    MarketplaceCategory(
      id: 'utilities',
      name: 'Utilities & Installations',
      icon: Icons.plumbing,
      subcategories: ['Plumbing', 'Sanitary', 'Electrical', 'Kitchen Essentials', 'Solar Panels', 'Epoxy'],
    ),
  ];

  static const List<MarketplaceProduct> products = [
    // Bricks
    MarketplaceProduct(
      id: 'b1',
      categoryId: 'masonry',
      subcategory: 'Bricks',
      name: 'Red Brick (9 x 4)',
      price: 12.0,
      unit: 'Piece',
      image: 'https://images.unsplash.com/photo-1517409419131-ab85ef67d8cd?w=400&q=80',
    ),
    MarketplaceProduct(
      id: 'b2',
      categoryId: 'masonry',
      subcategory: 'Bricks',
      name: 'Fly Ash Bricks',
      price: 6.5,
      unit: 'Piece',
      image: 'https://images.unsplash.com/photo-1515255452399-55e149c47cbe?w=400&q=80',
    ),
    MarketplaceProduct(
      id: 'b3',
      categoryId: 'masonry',
      subcategory: 'Bricks',
      name: 'Cement Blocks',
      price: 45.0,
      unit: 'Piece',
      image: 'https://images.unsplash.com/photo-1590494056253-ab4fc64fbe3d?w=400&q=80',
    ),
    MarketplaceProduct(
      id: 'b4',
      categoryId: 'masonry',
      subcategory: 'Bricks',
      name: 'ACC Blocks',
      price: 55.0,
      unit: 'Piece',
      image: 'https://images.unsplash.com/photo-1582139329536-e7284fece509?w=400&q=80',
    ),
    
    // Cement
    MarketplaceProduct(
      id: 'c1',
      categoryId: 'masonry',
      subcategory: 'Cement',
      name: 'Lenter Waterproof Cement',
      brand: 'UltraTech',
      price: 480.0,
      unit: 'Bag',
      image: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400&q=80',
    ),
    MarketplaceProduct(
      id: 'c2',
      categoryId: 'masonry',
      subcategory: 'Cement',
      name: 'Judai Birla Chetak',
      brand: 'Birla',
      price: 420.0,
      unit: 'Bag',
      image: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400&q=80',
    ),
    
    // Sand
    MarketplaceProduct(
      id: 's1',
      categoryId: 'masonry',
      subcategory: 'Sand',
      name: 'Narmada Sand (Chappai)',
      price: 4500.0,
      unit: 'Truck',
      image: 'https://images.unsplash.com/photo-1565134638781-f2f281e8eaf6?w=400&q=80',
    ),
    
    // Steel
    MarketplaceProduct(
      id: 'st1',
      categoryId: 'steel',
      subcategory: 'TMT Rebar',
      name: 'Kamdhenu TMT Steel (12mm)',
      brand: 'Kamdhenu',
      price: 65000.0,
      unit: 'Ton',
      image: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400&q=80',
    ),
    
    // Paint
    MarketplaceProduct(
      id: 'p1',
      categoryId: 'finishing',
      subcategory: 'Paint & Prep',
      name: 'Asian Paints Apex Royale',
      brand: 'Asian Paints',
      price: 3200.0,
      unit: '20L',
      image: 'https://images.unsplash.com/photo-1563806967664-cd2deac68d0e?w=400&q=80',
    ),
    
    // Gitti
    MarketplaceProduct(
      id: 'g1',
      categoryId: 'masonry',
      subcategory: 'Gitti',
      name: '10mm Blue Metal (House Construction)',
      price: 2400.0,
      unit: 'Ton',
      image: 'https://images.unsplash.com/photo-1541888946425-d81bb19480c5?w=400&q=80',
    ),
    MarketplaceProduct(
      id: 'g2',
      categoryId: 'masonry',
      subcategory: 'Gitti',
      name: '20mm Blue Metal (House Construction)',
      price: 2200.0,
      unit: 'Ton',
      image: 'https://images.unsplash.com/photo-1541888946425-d81bb19480c5?w=400&q=80',
    ),
    
    // Murrum
    MarketplaceProduct(
      id: 'm1',
      categoryId: 'masonry',
      subcategory: 'Murrum',
      name: 'Filter Murrum',
      price: 1800.0,
      unit: 'Truck',
      image: 'https://images.unsplash.com/photo-1598214886806-c87b84b7098b?w=400&q=80',
    ),

    // Choukhaat & Khidki
    MarketplaceProduct(
      id: 'ck1',
      categoryId: 'openings',
      subcategory: 'Frames (Choukhaat)',
      name: 'Premium Sagoon Teak Frame',
      price: 12000.0,
      unit: 'Piece',
      image: 'https://images.unsplash.com/photo-1517646288020-92efd6a36c69?w=400&q=80',
    ),
    MarketplaceProduct(
      id: 'ck2',
      categoryId: 'openings',
      subcategory: 'Windows (Khidki)',
      name: 'Modern PVC Sliding Window',
      price: 4500.0,
      unit: 'Piece',
      image: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400&q=80',
    ),

    // Finishing
    MarketplaceProduct(
      id: 'f1',
      categoryId: 'finishing',
      subcategory: 'Tiles & Stone',
      name: 'Karariya Premium Floor Tiles',
      price: 120.0,
      unit: 'SqFt',
      image: 'https://images.unsplash.com/photo-1563823251941-b9989d1e8d97?w=400&q=80',
    ),
    MarketplaceProduct(
      id: 'f2',
      categoryId: 'finishing',
      subcategory: 'Tiles & Stone',
      name: 'Polished Granite Slab',
      price: 350.0,
      unit: 'SqFt',
      image: 'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?w=400&q=80',
    ),
    MarketplaceProduct(
      id: 'f3',
      categoryId: 'finishing',
      subcategory: 'Tiles & Stone',
      name: 'Kadpa Stone (Kitchen Slab)',
      price: 250.0,
      unit: 'Piece',
      image: 'https://images.unsplash.com/photo-1588619951128-4449832267b2?w=400&q=80',
    ),
    MarketplaceProduct(
      id: 'f4',
      categoryId: 'finishing',
      subcategory: 'Paint & Prep',
      name: 'Birla White Wall Putty',
      brand: 'Birla',
      price: 850.0,
      unit: 'Bag',
      image: 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=400&q=80',
    ),
    
    // Utilities
    MarketplaceProduct(
      id: 'u1',
      categoryId: 'utilities',
      subcategory: 'Plumbing',
      name: 'High-Pressure PVC Pipe Set',
      price: 1200.0,
      unit: 'Set',
      image: 'https://images.unsplash.com/photo-1605559424843-9e4c22821626?w=400&q=80',
    ),
    MarketplaceProduct(
      id: 'u2',
      categoryId: 'utilities',
      subcategory: 'Electrical',
      name: 'Solar Panel System (1KW)',
      price: 55000.0,
      unit: 'Unit',
      image: 'https://images.unsplash.com/photo-1508514177221-188b1cf16e9d?w=400&q=80',
    ),
    MarketplaceProduct(
      id: 'u3',
      categoryId: 'utilities',
      subcategory: 'Kitchen Essentials',
      name: 'Stainless Steel Kitchen Sink',
      price: 3500.0,
      unit: 'Piece',
      image: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400&q=80',
    ),
  ];
}
