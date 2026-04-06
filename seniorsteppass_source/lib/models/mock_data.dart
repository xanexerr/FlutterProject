import 'index.dart';

// Mock Companies with realistic data
final List<CompanyModel> mockCompanies = [
  CompanyModel(
    id: '1',
    name: 'Google Thailand',
    department: 'Engineering',
    logoUrl:
        'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png',
    description:
        'Tech giant focused on innovation and cutting-edge technologies. Amazing culture and learning opportunities.',
    overallRating: 4.8,
    reviewCount: 45,
    location: 'Bangkok, Thailand',
    website: 'google.co.th',
    reviews: [
      ReviewModel(
        id: 'r1',
        reviewerName: 'Somchai Dev',
        position: 'Senior Engineer',
        content:
            'Great experience working here. Amazing mentorship and career growth. Highly recommend!',
        rating: 5.0,
        techStack: ['Flutter', 'Dart', 'Firebase'],
        date: DateTime.now().subtract(Duration(days: 10)),
      ),
      ReviewModel(
        id: 'r2',
        reviewerName: 'Niran Coder',
        position: 'Product Manager',
        content:
            'Excellent company culture and work-life balance. Very supportive team.',
        rating: 4.7,
        techStack: ['Kotlin', 'Java', 'Cloud'],
        date: DateTime.now().subtract(Duration(days: 20)),
      ),
    ],
  ),
  CompanyModel(
    id: '2',
    name: 'Microsoft Thailand',
    department: 'Cloud Solutions',
    logoUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Microsoft_logo.svg/1024px-Microsoft_logo.svg.png',
    description:
        'Leading cloud computing and enterprise solutions provider. Strong focus on Azure and AI.',
    overallRating: 4.6,
    reviewCount: 38,
    location: 'Bangkok, Thailand',
    website: 'microsoft.com/th-th',
    reviews: [
      ReviewModel(
        id: 'r3',
        reviewerName: 'Pornrat Cloud',
        position: 'Cloud Architect',
        content: 'Great opportunities to work with Azure and modern cloud technologies.',
        rating: 4.5,
        techStack: ['Azure', 'C#', 'Python'],
        date: DateTime.now().subtract(Duration(days: 15)),
      ),
      ReviewModel(
        id: 'r4',
        reviewerName: 'Jariya Systems',
        position: 'DevOps Engineer',
        content: 'Excellent infrastructure and tools. Very professional environment.',
        rating: 4.7,
        techStack: ['Docker', 'Kubernetes', 'Terraform'],
        date: DateTime.now().subtract(Duration(days: 25)),
      ),
    ],
  ),
  CompanyModel(
    id: '3',
    name: 'Facebook Thailand',
    department: 'Mobile Development',
    logoUrl:
        'https://upload.wikimedia.org/wikipedia/commons/5/51/Facebook_f_logo_%282019%29.svg',
    description:
        'Social media innovation hub. Work on products used by millions worldwide.',
    overallRating: 4.5,
    reviewCount: 32,
    location: 'Bangkok, Thailand',
    website: 'facebook.com',
    reviews: [
      ReviewModel(
        id: 'r5',
        reviewerName: 'Sukanya Mobile',
        position: 'Flutter Developer',
        content: 'Amazing experience building mobile apps at scale. Great team!',
        rating: 4.6,
        techStack: ['React Native', 'JavaScript', 'GraphQL'],
        date: DateTime.now().subtract(Duration(days: 30)),
      ),
    ],
  ),
  CompanyModel(
    id: '4',
    name: 'Ascend Money',
    department: 'FinTech',
    logoUrl:
        'https://www.ascendmoney.com/assets/images/brand/logomark.svg',
    description:
        'Leading financial technology platform in Southeast Asia. Innovation in payments and digital finance.',
    overallRating: 4.4,
    reviewCount: 28,
    location: 'Bangkok, Thailand',
    website: 'ascendmoney.com',
    reviews: [
      ReviewModel(
        id: 'r6',
        reviewerName: 'Wattana Finance',
        position: 'Backend Engineer',
        content: 'Exciting fintech challenges and talented team. Great learning experience.',
        rating: 4.4,
        techStack: ['Python', 'PostgreSQL', 'Docker'],
        date: DateTime.now().subtract(Duration(days: 5)),
      ),
    ],
  ),
  CompanyModel(
    id: '5',
    name: 'Uniqlo Thailand',
    department: 'IT & Systems',
    logoUrl:
        'https://www.uniqlo.com/common/images/logo/uniqlo-logo.svg',
    description:
        'Retail innovation and digital transformation. E-commerce and supply chain technology.',
    overallRating: 4.2,
    reviewCount: 22,
    location: 'Bangkok, Thailand',
    website: 'uniqlo.com/th/',
    reviews: [
      ReviewModel(
        id: 'r7',
        reviewerName: 'Pattaya Tech',
        position: 'Full Stack Developer',
        content: 'Good internship program with real project work. Supportive managers.',
        rating: 4.2,
        techStack: ['React', 'Node.js', 'MySQL'],
        date: DateTime.now().subtract(Duration(days: 12)),
      ),
    ],
  ),
];

// Mock Projects with realistic data
final List<ProjectModel> mockProjects = [
  ProjectModel(
    id: 'p1',
    title: 'AI-Powered Learning Platform',
    description:
        'Mobile app that uses machine learning to personalize student learning paths and recommend relevant courses.',
    author: 'Somchai Dev',
    imageUrl:
        'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400',
    tags: ['Flutter', 'AI', 'Machine Learning', 'Education'],
    categories: ['Software Engineer', 'Data Science'],
    teamMembers: [
      TeamMember(
        id: 'tm1',
        name: 'Somchai Dev',
        role: 'Project Lead, Mobile Dev',
      ),
      TeamMember(
        id: 'tm2',
        name: 'Niran AI',
        role: 'ML Engineer',
      ),
      TeamMember(
        id: 'tm3',
        name: 'Jariya Backend',
        role: 'Backend Developer',
      ),
    ],
    createdDate: DateTime.now().subtract(Duration(days: 60)),
    status: 'Active',
    views: 1250,
    likes: 340,
  ),
  ProjectModel(
    id: 'p2',
    title: 'IoT Smart Home Control',
    description:
        'Flutter app for controlling smart home devices (lights, temperature, security) with real-time updates and automation.',
    author: 'Niran IoT',
    imageUrl:
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
    tags: ['Flutter', 'IoT', 'Real-time', 'Home Automation'],
    categories: ['Internet Of Thing'],
    teamMembers: [
      TeamMember(
        id: 'tm4',
        name: 'Niran IoT',
        role: 'Hardware & Mobile',
      ),
      TeamMember(
        id: 'tm5',
        name: 'Wattana Embedded',
        role: 'Embedded Systems',
      ),
    ],
    createdDate: DateTime.now().subtract(Duration(days: 45)),
    status: 'Active',
    views: 890,
    likes: 256,
  ),
  ProjectModel(
    id: 'p3',
    title: 'E-Commerce Platform',
    description:
        'Full-stack e-commerce solution with payment integration, order tracking, and seller dashboard.',
    author: 'Sukanya Full Stack',
    imageUrl:
        'https://images.unsplash.com/photo-1523474253046-72967e0e0ed5?w=400',
    tags: ['React', 'Node.js', 'E-commerce', 'Payment Integration'],
    categories: ['Software Engineer'],
    teamMembers: [
      TeamMember(
        id: 'tm6',
        name: 'Sukanya Full Stack',
        role: 'Full Stack Lead',
      ),
      TeamMember(
        id: 'tm7',
        name: 'Pattaya Backend',
        role: 'Backend Lead',
      ),
      TeamMember(
        id: 'tm8',
        name: 'Jariya UI',
        role: 'UI/UX Designer',
      ),
      TeamMember(
        id: 'tm9',
        name: 'Somchai Frontend',
        role: 'Frontend Developer',
      ),
    ],
    createdDate: DateTime.now().subtract(Duration(days: 90)),
    status: 'Completed',
    views: 2150,
    likes: 542,
  ),
  ProjectModel(
    id: 'p4',
    title: 'Health & Fitness Tracker',
    description:
        'Cross-platform app for tracking daily workouts, nutrition, and health metrics with social features.',
    author: 'Pornchai Health',
    imageUrl:
        'https://images.unsplash.com/photo-1517836357463-d25ddfcbf042?w=400',
    tags: ['Flutter', 'Health Tech', 'Wearable', 'Social'],
    categories: ['Data Science'],
    teamMembers: [
      TeamMember(
        id: 'tm10',
        name: 'Pornchai Health',
        role: 'Product Lead',
      ),
      TeamMember(
        id: 'tm11',
        name: 'Niran Health Data',
        role: 'Data Science',
      ),
    ],
    createdDate: DateTime.now().subtract(Duration(days: 30)),
    status: 'Active',
    views: 650,
    likes: 182,
  ),
  ProjectModel(
    id: 'p5',
    title: 'Social Networking App',
    description:
        'Real-time chat, posts, and video streaming platform with end-to-end encryption and content moderation.',
    author: 'Wattana Social',
    imageUrl:
        'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=400',
    tags: ['React Native', 'WebSocket', 'Security', 'Real-time'],
    categories: ['Software Engineer', 'Cyber Security'],
    teamMembers: [
      TeamMember(
        id: 'tm12',
        name: 'Wattana Social',
        role: 'Architect',
      ),
      TeamMember(
        id: 'tm13',
        name: 'Jariya Security',
        role: 'Security Engineer',
      ),
      TeamMember(
        id: 'tm14',
        name: 'Sukanya Frontend',
        role: 'Frontend Lead',
      ),
      TeamMember(
        id: 'tm15',
        name: 'Somchai Video',
        role: 'Video Engineer',
      ),
      TeamMember(
        id: 'tm16',
        name: 'Pattaya Backend',
        role: 'Backend Lead',
      ),
    ],
    createdDate: DateTime.now().subtract(Duration(days: 75)),
    status: 'Active',
    views: 3200,
    likes: 890,
  ),
];

// Mock Users
final List<UserModel> mockUsers = [
  UserModel(
    id: 'u1',
    name: 'Somchai Phongsavanh',
    studentId: '6420001',
    faculty: 'Faculty of Engineering',
    role: 'User',
    email: 'somchai@student.chula.ac.th',
    bio: 'Mobile developer passionate about Flutter and cross-platform development.',
  ),
  UserModel(
    id: 'u2',
    name: 'Niran Sanguansap',
    studentId: '6420002',
    faculty: 'Faculty of Science',
    role: 'User',
    email: 'niran@student.chula.ac.th',
    bio: 'AI and Machine Learning enthusiast. Currently learning deep learning.',
  ),
  UserModel(
    id: 'u3',
    name: 'Admin User',
    studentId: 'ADMIN001',
    faculty: 'Faculty of Engineering',
    role: 'Admin',
    email: 'admin@seniorstp.com',
    bio: 'Platform administrator.',
  ),
];
