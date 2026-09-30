/** @type {import('@commitlint/types').UserConfig} */
export default {
  extends: ['@commitlint/config-conventional'],
  rules: {
    // SDLC artifact types (intent/spec/plan) on top of the conventional set.
    // Keep in sync with the PR Slug workflow's `types` input.
    'type-enum': [
      2,
      'always',
      ['feat', 'fix', 'test', 'refactor', 'perf', 'docs', 'chore', 'ci', 'build', 'style', 'intent', 'spec', 'plan'],
    ],
    // config-conventional's subject-case rule already rejects Sentence/Start/PascalCase/UPPER
    // subjects while still allowing proper nouns later in the subject ("add Career tab").
    'header-max-length': [2, 'always', 100],
  },
};
