import 'index.dart';

// Mock Companies with realistic data
final List<CompanyModel> mockCompanies = [
  CompanyModel(
    id: '1',
    company_name: 'Google Thailand',
    department: 'Engineering',
    logo_url:
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
        reviewer_id: 'r1',
        position: 'Senior Engineer',
        comment:
            'Great experience working here. Amazing mentorship and career growth. Highly recommend!',
        rating: 5.0,
        techStack: ['Flutter', 'Dart', 'Firebase'],
        timestamp: DateTime.now().subtract(Duration(days: 10)),
        company: 'Google Thailand',
      ),
      ReviewModel(
        id: 'r2',
        reviewer_id: 'r2',
        position: 'Product Manager',
        comment:
            'Excellent company culture and work-life balance. Very supportive team.',
        rating: 4.7,
        techStack: ['Kotlin', 'Java', 'Cloud'],
        timestamp: DateTime.now().subtract(Duration(days: 20)),
        company: 'Google Thailand',
      ),
    ],
  ),
  CompanyModel(
    id: '2',
    company_name: 'Microsoft Thailand',
    department: 'Cloud Solutions',
    logo_url:
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
        reviewer_id: 'r3',
        position: 'Cloud Architect',
        comment: 'Great opportunities to work with Azure and modern cloud technologies.',
        rating: 4.5,
        techStack: ['Azure', 'C#', 'Python'],
        timestamp: DateTime.now().subtract(Duration(days: 15)),
        company: 'Microsoft Thailand',
      ),
      ReviewModel(
        id: 'r4',
        reviewer_id: 'r4',
        position: 'DevOps Engineer',
        comment: 'Excellent infrastructure and tools. Very professional environment.',
        rating: 4.7,
        techStack: ['Docker', 'Kubernetes', 'Terraform'],
        timestamp: DateTime.now().subtract(Duration(days: 25)),
        company: 'Microsoft Thailand',
      ),
    ],
  ),
  CompanyModel(
    id: '3',
    company_name: 'Facebook Thailand',
    department: 'Mobile Development',
    logo_url:
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
        reviewer_id: 'r5',
        position: 'Flutter Developer',
        comment: 'Amazing experience building mobile apps at scale. Great team!',
        rating: 4.6,
        techStack: ['React Native', 'JavaScript', 'GraphQL'],
        timestamp: DateTime.now().subtract(Duration(days: 30)),
        company: 'Facebook Thailand',
      ),
    ],
  ),
  CompanyModel(
    id: '4',
    company_name: 'Ascend Money',
    department: 'FinTech',
    logo_url:
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
        reviewer_id: 'r6',
        position: 'Backend Engineer',
        comment: 'Exciting fintech challenges and talented team. Great learning experience.',
        rating: 4.4,
        techStack: ['Python', 'PostgreSQL', 'Docker'],
        timestamp: DateTime.now().subtract(Duration(days: 5)),
        company: 'Ascend Money',
      ),
    ],
  ),
  CompanyModel(
    id: '5',
    company_name: 'Uniqlo Thailand',
    department: 'IT & Systems',
    logo_url:
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
        reviewer_id: 'r7',
        position: 'Full Stack Developer',
        comment: 'Good internship program with real project work. Supportive managers.',
        rating: 4.2,
        techStack: ['React', 'Node.js', 'MySQL'],
        timestamp: DateTime.now().subtract(Duration(days: 12)),
        company: 'Uniqlo Thailand',
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
    owner_id: 'Somchai Dev',
    image_url:
        'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400',
    tags: ['Flutter', 'AI', 'Machine Learning', 'Education'],
    categories: ['Software Engineer', 'Data Science'],
    members: [
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
    timestamp: DateTime.now().subtract(Duration(days: 60)),
    status: 'Active',
    views: 1250,
    likes: 340,
  ),
  ProjectModel(
    id: 'p2',
    title: 'IoT Smart Home Control',
    description:
        'Flutter app for controlling smart home devices (lights, temperature, security) with real-time updates and automation.',
    owner_id: 'Niran IoT',
    image_url:
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
    tags: ['Flutter', 'IoT', 'Real-time', 'Home Automation'],
    categories: ['Internet Of Thing'],
    members: [
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
    timestamp: DateTime.now().subtract(Duration(days: 45)),
    status: 'Active',
    views: 890,
    likes: 256,
  ),
  ProjectModel(
    id: 'p3',
    title: 'E-Commerce Platform',
    description:
        'Full-stack e-commerce solution with payment integration, order tracking, and seller dashboard.',
    owner_id: 'Sukanya Full Stack',
    image_url:
        'https://images.unsplash.com/photo-1523474253046-72967e0e0ed5?w=400',
    tags: ['React', 'Node.js', 'E-commerce', 'Payment Integration'],
    categories: ['Software Engineer'],
    members: [
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
    timestamp: DateTime.now().subtract(Duration(days: 90)),
    status: 'Completed',
    views: 2150,
    likes: 542,
  ),
  ProjectModel(
    id: 'p4',
    title: 'Health & Fitness Tracker',
    description:
        'Cross-platform app for tracking daily workouts, nutrition, and health metrics with social features.',
    owner_id: 'Pornchai Health',
    image_url:
        'https://images.unsplash.com/photo-1517836357463-d25ddfcbf042?w=400',
    tags: ['Flutter', 'Health Tech', 'Wearable', 'Social'],
    categories: ['Data Science'],
    members: [
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
    timestamp: DateTime.now().subtract(Duration(days: 30)),
    status: 'Active',
    views: 650,
    likes: 182,
  ),
  ProjectModel(
    id: 'p5',
    title: 'Social Networking App',
    description:
        'Real-time chat, posts, and video streaming platform with end-to-end encryption and content moderation.',
    owner_id: 'Wattana Social',
    image_url:
        'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=400',
    tags: ['React Native', 'WebSocket', 'Security', 'Real-time'],
    categories: ['Software Engineer', 'Cyber Security'],
    members: [
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
    timestamp: DateTime.now().subtract(Duration(days: 75)),
    status: 'Active',
    views: 3200,
    likes: 890,
  ),
];

// Mock Users
final List<UserModel> mockUsers = [
  UserModel(
    id: 'u1',
    full_name: 'Somchai Phongsavanh',
    student_id: '6420001',
    faculty: 'Faculty of Engineering',
    role: 'User',
    email: 'somchai@student.chula.ac.th',
    bio: 'Mobile developer passionate about Flutter and cross-platform development.',
  ),
  UserModel(
    id: 'u2',
    full_name: 'Niran Sanguansap',
    student_id: '6420002',
    faculty: 'Faculty of Science',
    role: 'User',
    email: 'niran@student.chula.ac.th',
    bio: 'AI and Machine Learning enthusiast. Currently learning deep learning.',
  ),
  UserModel(
    id: 'u3',
    full_name: 'Admin User',
    student_id: 'ADMIN001',
    faculty: 'Faculty of Engineering',
    role: 'Admin',
    email: 'admin@seniorstp.com',
    bio: 'Platform administrator.',
  ),
];
