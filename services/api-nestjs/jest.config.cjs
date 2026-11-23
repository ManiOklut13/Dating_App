/**
 * Jest configuration for the YoUnMe NestJS API.
 * Sources are ESM-style TypeScript (package "type": "module", NodeNext,
 * .js import suffixes), so tests run through Jest's native ESM loader
 * (enabled via --experimental-vm-modules in the npm test script) and
 * relative .js suffixes are mapped back to their .ts sources.
 */
module.exports = {
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  testMatch: ['**/*.spec.ts'],
  moduleFileExtensions: ['ts', 'js', 'json'],
  extensionsToTreatAsEsm: ['.ts'],
  transform: {
    '^.+\\.ts$': [
      'ts-jest',
      {
        tsconfig: '<rootDir>/tsconfig.spec.json',
        useESM: true,
        // TS151002: hybrid module kind (NodeNext) requires isolatedModules.
        // The suite intentionally keeps full type-checking, so the advisory is ignored.
        diagnostics: { ignoreCodes: [151002] },
      },
    ],
  },
  moduleNameMapper: {
    '^(\\.{1,2}/.*)\\.js$': '$1',
  },
};
