const webpack = require('webpack');
const path = require('path');
const fs = require('fs');

const ReactRefreshWebpackPlugin = require('@pmmmwh/react-refresh-webpack-plugin');
const { TsconfigPathsPlugin } = require('tsconfig-paths-webpack-plugin');
const HtmlWebpackPlugin = require('html-webpack-plugin');


const TerserPlugin = require('terser-webpack-plugin');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');



const WEBPACK_CONFIG = {
  mode: 'production',
  entry: './src/Core/main.tsx',
  output: {
    path: path.resolve(__dirname, '../build'),
    filename: (pathData) => {
      if (pathData.chunk.name === 'main') {
        return 'Nui/[name].[contenthash].js';
      }
      return '[name]/[name].[contenthash].js';
    },
    chunkFilename: 'Nui/[name].[contenthash].js',
    assetModuleFilename: 'Nui/assets/[name].[contenthash][ext][query]',
    clean: true,

  },
  resolve: {
    extensions: ['.tsx', '.ts', '.js'],
    plugins: [new TsconfigPathsPlugin()],
  },

  module: {
    rules: [
      {
        test: /\.(js|jsx|ts|tsx)$/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: [],
            plugins: [],
          },

        },
        exclude: [/node_modules/],
      },
      {
        test: /\.css$/i,
        use: ['style-loader', 'css-loader', 'postcss-loader'],
      },
      {
        test: /\.(png|jpe?g|gif|svg)$/i,
        type: 'asset/resource',
        exclude: [/node_modules/],
      },
      {
        test: /\.(mp3|ogg)$/, 
        type: 'asset/resource',
        exclude: [/node_modules/],
      }

    ],
  },

  optimization: {
    minimize: true,
    minimizer: [new TerserPlugin({
      extractComments: false,
      terserOptions: {
        format: {
          comments: false,
        },
      }
    })],  
    splitChunks: {
      cacheGroups: {
        Core: {
          test: /[\\/]src[\\/]Core[\\/].*\.(jsx|js|ts|tsx)$/,
          chunks: 'all',
          name: 'Core',
          enforce: true,
        },
      },
    },
  },

  plugins: [
    new CleanWebpackPlugin(),
    /*     new BabelMinifyWebpackPlugin(), */
    new ReactRefreshWebpackPlugin(),
    new HtmlWebpackPlugin({
      template: './index.html',
    }),
    new webpack.ProvidePlugin({
      "React": "react",
    }),



  ],


};

module.exports = [WEBPACK_CONFIG];


