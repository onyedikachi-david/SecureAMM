module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: 'tsconfig.json',
  },
  plugins: ['@typescript-eslint', 'unused-imports'],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'prettier',
  ],
  rules: {
    '@typescript-eslint/no-unused-vars': 'warn',
    '@typescript-eslint/no-floating-promises': 'error',
    '@typescript-eslint/no-misused-promises': [
      'error',
      {
        checksVoidReturn: false,
      },
    ],
    'unused-imports/no-unused-imports-ts': 'warn',
    'no-shadow': 'warn',
    'no-dupe-else-if': 'warn',
    'no-dupe-keys': 'warn',
    'no-duplicate-imports': 'warn',
    'no-self-compare': 'warn',
    'no-self-assign': 'warn',
    'no-unreachable': 'warn',
  },
};
