/*
 * AppController.j
 * CS215Final
 *
 * Created by Randall Luecke on November 24, 2010.
 * Copyright 2010, RCLConcepts, LLC All rights reserved.
 */

@import <Foundation/CPObject.j>
@import <Foundation/CPDate.j>
@import "Image.j"


@implementation AppController : CPObject
{
    @outlet CPWindow    theWindow; //this "outlet" is connected automatically by the Cib
    @outlet CPBox       originalBox;
    @outlet CPBox       newBox;
    @outlet CPTextField originalWidth @accessors;
    @outlet CPTextField originalHeight @accessors;
    @outlet CPImageView imageView;
    @outlet CPTextField blockSize @accessors;
    @outlet CPTextField blockHeight;
    @outlet CPTextField newWidth;
    @outlet CPTextField newHeight;

            ImageController imageController;
}

- (@action)loadImage:(id)sender
{
    imageController = [[ImageController alloc] init];

    [imageController newImage:"Resources/sample2.jpg"];
    //[imageController newImage:"Resources/red.png"];
    [imageController setDelegate:self];
}

- (void)setImage:(CPImage)anImage
{
    [imageView setImage:anImage];
}

- (void)controlTextDidChange:(CPNotification)aNote
{
    var textfield = [aNote object],
        width = [[originalWidth stringValue] stringByReplacingOccurrencesOfString:"px" withString:""],
        height = [[originalHeight stringValue] stringByReplacingOccurrencesOfString:"px" withString:""], 
        ratio = parseInt(width) / parseInt(height),
        blockWidthValue = [textfield stringValue];
        
    blockWidthValue.replace(/[^0-9]/g, "");

    var blockHeightValue = parseInt(parseInt(blockWidthValue) / ratio);

    if (isNaN(blockHeightValue))
        blockHeightValue = 0;

    var newWidthValue = parseInt(width/blockWidthValue),
        newHeightValue = parseInt(newWidthValue/ratio);

    if (isNaN(newWidthValue))
        newWidthValue = 0;

    if (isNaN(newHeightValue))
        newHeightValue = 0;

    [blockHeight setStringValue:blockWidthValue + "px"];
    [newHeight setStringValue:newHeightValue+"px"];
    [newWidth setStringValue:newWidthValue+"px"];
}

- (void)controlTextDidEndEditing:(CPNotification)aNote
{
    if (![[aNote object] stringValue])
        [[aNote object] setStringValue:"0px"];
}

- (@action)addRed:(id)sender
{
    [imageController addRed:sender];
}

- (@action)addBlue:(id)sender
{
    [imageController addBlue:sender];
}

- (@action)addGreen:(id)sender
{
    [imageController addGreen:sender];
}

- (@action)resize:(id)sender
{
    [imageController resize:[blockSize intValue]];
}
@end
