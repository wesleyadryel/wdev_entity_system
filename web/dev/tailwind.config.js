module.exports = {
  darkMode: 'class', // or 'media' or 'class'
  whiteModule: 'class', // Defina sua nova variante de cor
  content: [
    "./src/Modules/**/*.{js,ts,jsx,tsx}",
    "./src/Core/**/*.{js,ts,jsx,tsx}",
    'node_modules/flowbite-react/**/*.{js,jsx,ts,tsx}'
  ],
  theme: {

    extend: {

    },
    addBase: {

    },
    screens: {
      'desktop-sm': {'max': '1224px',},
      'desktop-ultrawide': {'min': '1800px',}
      /*   'tabletPanel': {'max': '1105px'}, */
      // => @media (min-width: 640px) { ... }

    },

  },
  variants: {
    backgroundColor: ['responsive', 'dark', 'light', 'whiteModule'],
    extend: {
      outline: [],
    },
  },

  plugins: [
    require('flowbite/plugin'),
    require('tailwindcss-themer')({
      defaultTheme: {
        // put the default values of any config you want themed
        // just as if you were to extend tailwind's theme like normal https://tailwindcss.com/docs/theme#extending-the-default-theme
        extend: {
          // colors is used here for demonstration purposes
          colors: {
            primary: 'red'
          }
        }
      },
      themes: [
       
      ]
    }),




  ]
}