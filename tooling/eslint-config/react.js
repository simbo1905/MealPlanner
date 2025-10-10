module.exports = {
  extends: [
    './index.js',
    'next/core-web-vitals',
    'prettier'
  ],
  env: {
    browser: true,
    es2022: true,
    node: true
  },
  parserOptions: {
    ecmaFeatures: {
      jsx: true
    }
  }
}
