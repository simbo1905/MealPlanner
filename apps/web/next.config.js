/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  poweredByHeader: false,
  eslint: {
    ignoreDuringBuilds: true,
  },
  experimental: {
    turbo: {
      rules: {
        '*.svg': {
          loaders: ['@svgr/webpack'],
          as: '*.js',
        },
      },
    },
  },
  // Enable static export for mobile app integration
  output: 'export',
  distDir: 'dist',
  // Remove image optimization for static export
  images: {
    unoptimized: true,
  },
  // Configure for mobile webview
  assetPrefix: undefined,
  basePath: '',
}

export default nextConfig
