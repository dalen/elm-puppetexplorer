var path = require('path');

module.exports = {
  entry: {
    app: [
      path.resolve(__dirname, 'src', 'index.js'),
      path.resolve(__dirname, 'src', 'index.html'),
      path.resolve(__dirname, 'src', 'config.json')
    ]
  },

  output: {
    path: path.resolve(__dirname + '/dist'),
    filename: '[name].js'
  },

  module: {
    rules: [
      {
        test: /\.(css|scss)$/,
        use: ['file-loader', 'extract-loader', 'style-loader', 'css-loader']
      },
      {
        test: /\.(png|ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: 'file-loader'
      },
      {
        test: /\.html$/,
        exclude: /bower_components/,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: '[name].[ext]'
            }
          },
          {
            loader: 'extract-loader'
          },
          {
            loader: 'html-loader',
            options: {
              attrs: ['img:src']
            }
          }
        ]
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: 'elm-webpack-loader?verbose=true&warn=true'
      },
      {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: 'url-loader?limit=10000&mimetype=application/font-woff'
      },
      {
        test: /config\.json$/,
        loader: 'file-loader',
        options: {
          name: '[name].[ext]'
        }
      }
    ],

    noParse: /\.elm$/
  },

  devServer: {
    inline: true,
    stats: { colors: true },
    historyApiFallback: {
      disableDotRule: true // certnames usually contain dots
    },
    proxy: {
      '/api': {
        target: process.env.PUPPETDB_URL || 'http://puppetdb.puppetexplorer.io',
        pathRewrite: { '^/api': '' }
      }
    }
  }
};
