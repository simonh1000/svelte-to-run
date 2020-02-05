const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const path = require("path");

const mode = process.env.NODE_ENV || "development";
const prod = mode === "production";
const dev = !prod;

module.exports = {
    entry: {
        bundle: ["./src/main.js"]
    },
    resolve: {
        alias: {
            svelte: path.resolve("node_modules", "svelte")
        },
        extensions: [".mjs", ".js", ".svelte", ".scss", "*.css"],
        mainFields: ["svelte", "browser", "module", "main"]
    },
    output: {
        path: __dirname + "/public",
        filename: "[name].js",
        chunkFilename: "[name].[id].js"
    },
    module: {
        rules: [
            {
                test: /\.svelte$/,
                use: {
                    loader: "svelte-loader-hot",
                    options: {
                        dev,
                        hotReload: true,
                        hotOptions: {
                            // whether to preserve local state (i.e. any `let` variable) or
                            // only public props (i.e. `export let ...`)
                            noPreserveState: false,
                            // optimistic will try to recover from runtime errors happening
                            // during component init. This goes funky when your components are
                            // not pure enough.
                            optimistic: true
                        }
                    }
                }
            },
            {
                test: /\.(sa|sc)ss$/,
                use: [
                    "style-loader",
                    MiniCssExtractPlugin.loader,
                    "css-loader",
                    {
                        loader: "sass-loader",
                        options: {
                            sassOptions: {
                                includePaths: ["./src/styles", "./node_modules"]
                            }
                        }
                    }
                ]
            },
            {
                test: /\.css$/,
                use: [
                    MiniCssExtractPlugin.loader,
                    "css-loader",
                    "postcss-loader"
                ]
            }
        ]
    },
    mode,
    plugins: [
        new MiniCssExtractPlugin({
            filename: "[name].css"
        })
    ],
    devtool: prod ? false : "source-map",
    devServer: {
        contentBase: "public",
        historyApiFallback: true,
        hot: true,
        overlay: true
    }
};
