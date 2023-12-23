import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tsconfigPaths from 'vite-tsconfig-paths'
import EnvironmentPlugin from 'vite-plugin-environment';


// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    react(),
    tsconfigPaths(),
    EnvironmentPlugin('all')
  ],
  base: './',
  build: {
    outDir: 'build',
    target: 'esnext',
    assetsDir: 'assets',
    sourcemap: false,
    rollupOptions: {
      output: {
        entryFileNames: '[name]/index.[hash].js',
        chunkFileNames: '[name]/[name].[hash].js',
        assetFileNames: '[name].[hash].[ext]',
      },
    },


  },
});