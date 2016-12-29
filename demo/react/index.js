const { range, shuffle, sortBy } = require('lodash');

var items = range(0, 1000).map( () => shuffle( range(1, 9) ) );
var order = range(0, 1000);

const col = 0;


console.time('sort');
const new_order = sortBy(order, row => items[row][col]);
console.timeEnd('sort');

