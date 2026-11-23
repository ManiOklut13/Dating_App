/**
 * Custom Jest resolver for ESM TypeScript projects.
 * Remaps .js imports to .ts so jest finds TypeScript source files.
 * Must be CommonJS (.cjs).
 */

const path = require('path');

module.exports = (request, options) => {
  // Remap relative .js imports → .ts
  if (request.startsWith('.') && request.endsWith('.js')) {
    const tsRequest = request.slice(0, -3) + '.ts';
    try {
      return options.defaultResolver(tsRequest, options);
    } catch {
      // .ts not found — fall through to try original .js
    }
  }
  return options.defaultResolver(request, options);
};
