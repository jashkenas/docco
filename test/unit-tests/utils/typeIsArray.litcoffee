    typeIsArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'
    module.exports = typeIsArray