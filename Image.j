var RLColorRed = 0,
    RLColorGreen = 1,
    RLColorBlue = 2,
    RLColorAlpha = 3;

// all public methods in the object return a new image
ImageManipulation = {

    addColor: function(canvas, imageData, color)
    {
        var i = color,
            count = imageData.data.length;
    
        for (; i < count; i += 4)
            // at this point i represents the red color we must add to get to the other values
            imageData.data[i] = MIN(255, imageData.data[i] + 10);
    
        canvas.getContext("2d").putImageData(imageData, 0, 0);
    
        return canvas.toDataURL("image/png");
    },

    /*
        asyncronous
    */
    resize: function(canvas, imageData, width, height, blockWidth, callback)
    {
        var ctx = canvas.getContext("2d"),
            newSize = CGSizeMake(MIN(FLOOR(width/blockWidth), width),MIN(FLOOR(height/blockWidth), width)),
            newData = ctx.createImageData(newSize.width, newSize.height);

        //threads would be cool
        var worker = new Worker("manipulateImage.js");
        worker.postMessage({"imageData":imageData, "width":width, "height":height, "blockWidth":blockWidth, "newData":newData});

        worker.onmessage = function(e){
            //resize the canvas
            canvas.width = e.data.width;
            canvas.height = e.data.height;

            //draw
            ctx.putImageData(e.data,0,0);

            //update
            callback(canvas.toDataURL("image/png"));
        };
    }
}


@implementation ImageController : CPObject
{
    id      delegate @accessors;
    id      _image;
    DOMImageData imageData;
    DOMElement canvas;
}

- (void)newImage:(CPSting)anImageAddress
{
    _image = [[CPImage alloc] initWithContentsOfFile:anImageAddress];
    [_image setDelegate:self];
}

- (void)imageDidLoad:(CPNotification)aNote
{
    [self calculateImageColors];
}

- (void)calculateImageColors
{
    canvas = document.createElement("canvas");

    var context = canvas.getContext("2d"),
        size = [_image size];

    canvas.width = size.width;
    canvas.height = size.height;

    // _image is a private ivar in CPImage
    context.drawImage(_image._image,0,0,size.width,size.height);

    imageData = context.getImageData(0,0,size.width,size.height);

    [[delegate originalWidth] setStringValue:size.width];
    [[delegate originalHeight] setStringValue:size.height];
    [delegate controlTextDidChange:[CPNotification notificationWithName:CPControlTextDidChangeNotification object:[delegate blockSize] userInfo:nil]];

    [self _setImageData:canvas.toDataURL("image/png")];
}

- (void)_setImageData:(CPString)data
{
    _image = [[CPImage alloc] initWithContentsOfFile:data];
    [delegate setImage:_image];
}

- (void)addRed:(id)sender
{
    [self _setImageData:ImageManipulation.addColor(canvas, imageData, RLColorRed)];
}

- (void)addBlue:(id)sender
{
    [self _setImageData:ImageManipulation.addColor(canvas, imageData, RLColorBlue)];
}

- (void)addGreen:(id)sender
{
    [self _setImageData:ImageManipulation.addColor(canvas, imageData, RLColorGreen)];
}

- (void)resize:(int)blockSize
{
    var callback = function(data){
        [self newImage:data];
    }
    ImageManipulation.resize(canvas, imageData, [_image size].width, [_image size].height, blockSize, callback);
}


@end
