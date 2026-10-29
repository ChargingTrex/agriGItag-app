// ESLint flat config for the portal.
// Serves: CLAUDE.md §5 (TypeScript JSDoc @param/@returns/@throws, enforced here), plan §7.3 P00.
// Called by: `npm run lint` and the CI `portal` job (apps/portal/ci-job.yml).
//
// DECISION D-018: typescript-eslint strictTypeChecked + eslint-plugin-jsdoc instead of a hand-written doc checker.
//   ADV: the documentation standard is enforced mechanically on every function, with type-aware lint rules.
//   COMPROMISE: type-aware linting is slower (needs the TS program); inline callbacks such as `.map((x) => ...)`
//   are exempt from require-jsdoc because a doc block on every lambda would bury the code.
import js from '@eslint/js';
import { defineConfig } from 'eslint/config';
import prettier from 'eslint-config-prettier';
import jsdoc from 'eslint-plugin-jsdoc';
import reactHooks from 'eslint-plugin-react-hooks';
import tseslint from 'typescript-eslint';

export default defineConfig(
  {
    ignores: [
      'dist',
      'node_modules',
      'public',
      'src/api/generated',
      'playwright-report',
      'test-results',
    ],
  },
  js.configs.recommended,
  tseslint.configs.strictTypeChecked,
  {
    languageOptions: {
      parserOptions: { projectService: true, tsconfigRootDir: import.meta.dirname },
    },
  },
  reactHooks.configs.flat.recommended,
  jsdoc.configs['flat/recommended-typescript-error'],
  {
    rules: {
      'jsdoc/require-jsdoc': [
        'error',
        {
          publicOnly: false,
          require: {
            FunctionDeclaration: true,
            MethodDefinition: true,
            ClassDeclaration: true,
            ArrowFunctionExpression: false,
            FunctionExpression: false,
          },
          contexts: [
            'VariableDeclarator > ArrowFunctionExpression',
            'VariableDeclarator > FunctionExpression',
            'ExportDefaultDeclaration > ArrowFunctionExpression',
            'Property > FunctionExpression',
          ],
        },
      ],
      'jsdoc/require-description': 'error',
      'jsdoc/require-param': 'error',
      'jsdoc/require-returns': 'error',
      'jsdoc/require-throws': 'error',
    },
  },
  { files: ['**/*.js'], extends: [tseslint.configs.disableTypeChecked] },
  prettier,
);
