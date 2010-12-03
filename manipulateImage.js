var MIN = Math.min,
    MAX = Math.max,
    FLOOR = Math.floor;

onmessage = function(e)
{
    // data = {imageData, width, height, blockWidth, newData}
    var message = e.data;

    resize(message.imageData, message.width, message.height, message.blockWidth, message.newData);
}

/*
    Averages a block of pixels
    returns an array with a length of 4
    0: red
    1: green
    2: blue
    3: alpha
*/
avgColorOfBlock = function(pixels)
{
    var newPixel = [],
        row = red = blue = green = alpha = 0,
        totalRows = pixels.length,
        totalColumns = pixels[0].length,
        totalPx = totalRows * totalColumns;

    for (; row < totalRows; row++)
    {
        var column = 0;
        for (; column < totalColumns; column++)
        {
            red   += pixels[row][column].red;
            green += pixels[row][column].green;
            blue  += pixels[row][column].blue;
            alpha += pixels[row][column].alpha;
        }
    }

    newPixel.push(FLOOR(red / totalPx));
    newPixel.push(FLOOR(green / totalPx));
    newPixel.push(FLOOR(blue / totalPx));
    newPixel.push(FLOOR(alpha / totalPx));

    return newPixel;
}


resize = function(imageData, width, height, blockWidth, newData)
    {
        var rowIndex = 0,
            count = imageData.data.length,
            increment = blockWidth *4,
            oldData = imageData.data,
            newIndex = -1,
            blockHeight = blockWidth / (width/height);



            // loop through a block width, then drop down to the next row (width)
            for (; rowIndex < height; rowIndex+=blockHeight)
            {
                var columnIndex = 0;
                for (; columnIndex < width; columnIndex+=blockWidth)
                {
                    var block = [];
                    for (var blockRow = 0; blockRow < blockHeight; blockRow++)
                    {
                        var rowPx = [];
                        for (var blockColumn = 0; blockColumn < blockWidth; blockColumn++)
                        {
                            var px = {};
                            px.red   = oldData[(((rowIndex + blockRow)*(width*4)) + ((columnIndex + blockColumn)*4)) + 0];
                            px.green = oldData[(((rowIndex + blockRow)*(width*4)) + ((columnIndex + blockColumn)*4)) + 1];
                            px.blue  = oldData[(((rowIndex + blockRow)*(width*4)) + ((columnIndex + blockColumn)*4)) + 2];
                            px.alpha = oldData[(((rowIndex + blockRow)*(width*4)) + ((columnIndex + blockColumn)*4)) + 3];
                            rowPx.push(px);
                        }
                        //at the end of all the columns we pop it onto the row array
                        block.push(rowPx);
                    }
                    // at the end of the block we need to calculate its averate color

                    var avg = avgColorOfBlock(block);;
                    newData.data[++newIndex] = avg[0];
                    newData.data[++newIndex] = avg[1];
                    newData.data[++newIndex] = avg[2];
                    newData.data[++newIndex] = avg[3];
                }
            }

            // now that I'm done looping through everything 
            //postMessage("row"+rowIndex);
            postMessage(newData);
    }