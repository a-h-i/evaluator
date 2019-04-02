const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const CleanWebpackPlugin = require('clean-webpack-plugin');
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const DashboardPlugin = require('webpack-dashboard/plugin');
const SystemBellPlugin = require('system-bell-webpack-plugin');
const path = require('path');



const nodeEnv = process.env.NODE_ENV || 'development';
const apiPortEnv = process.env.API_PORT_WEBPACK || '3000'
const apiPort = parseInt(apiPortEnv);
const webpackDevPortEnv = process.env.WEBPACK_DEV_PORT || '9000';
const webpackDevPort = parseInt(webpackDevPortEnv);


// 0.0.0.0 for external connections/all interfaces.
// I.e in vagrant or forwarding from android
const webPackDevHost = process.env.WEBPACK_DEV_HOST || 'localhost';
const isProduction = nodeEnv === 'production';

let conf = {
  context: path.resolve(__dirname, './src'),
  entry: {
    app: './main.js'
  },
  output: {
    path: path.resolve(__dirname, './dist'),
    filename: '[name]-[hash].js'
  },
  plugins: [],
  module: {
    rules: []
  },
  devtool: 'source-map'
};

conf.optimization = {
  splitChunks: {
    cacheGroups: {
      styles: {
        name: 'styles',
        test: /\.css$/,
        chunks: 'all',
        enforce: true
      }
    }
  }
};

conf.mode = isProduction ? 'production' : 'development';
conf.resolve = {
  modules: ['node_modules'],
  extensions: ['.js']
};
//
// ─── CONFIGURE PLUGINS ──────────────────────────────────────────────────────────
//



conf.plugins.push(new HtmlWebpackPlugin({
  filename: 'index.html',
  template: 'index.html',
  inject: 'body',
  stats: {
    children: false
  }
}));

conf.plugins.push(new MiniCssExtractPlugin({
  filename: "[name]-[contenthash].css",
}));

conf.plugins.push(new CleanWebpackPlugin({
  verbose: true,
  dry: false,
  cleanStaleWebpackAssets: true
}));

conf.plugins.push(new DashboardPlugin({
  port: webpackDevPort
}));

conf.plugins.push(new SystemBellPlugin());
//
// ─── CONFIGURE LOADERS ──────────────────────────────────────────────────────────
//



let styleModule = {
  test: /\.(sass|scss)$/,
  use: [
    MiniCssExtractPlugin.loader,
    'css-loader',
    {
      loader: 'postcss-loader',
      options: {
        plugins: () => ([
          require('autoprefixer'),
        ]),
      },
    },
    'fast-sass-loader'
  ]
};

let jsModule = {
  test: /\.js$/,
  exclude: [/node_module/],
  use: ['babel-loader', {
    loader: 'eslint-loader',
    options: {
      emitWarning: false,
      emitError: false,
      cache: true,
      failOnWarning: false,
      failOnError: false
    }
  }]
};

let htmlLoader = {
  test: /\.html$/,
  use: [{
    loader: 'html-loader',
    options: {
      minimize: isProduction
    }
  }]
};



conf.module.rules.push(jsModule);
conf.module.rules.push(htmlLoader);
conf.module.rules.push(styleModule);


//
// ─── DEV SERVER CONFIG ──────────────────────────────────────────────────────────
//

  conf.devServer = {
    overlay: {
      errors: true,
      warnings: true,
    },
    compress: true,
    proxy: {
      '/api': {
        target: `http:localhost:${apiPort}`,
        secure: false
      }
    },
    port: webpackDevPort,
    host: webPackDevHost
  }

if (!isProduction) {
  conf.plugins.push(new webpack.HotModuleReplacementPlugin());
  conf.devServer.hot = true;
}


module.exports = conf;