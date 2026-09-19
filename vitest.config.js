import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    // The specs build their own JSDOM window so they can load real jQuery and
    // the vendored jQuery-File-Upload in the order sprockets does.
    environment: 'node',
    include: ['spec/javascripts/**/*.test.js']
  }
})
