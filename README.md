# ui-queueview

An instance of UIQueueView  is a means for displaying and editing hierarchical lists of information.

A queue view display a list of items stacked one on another. Users can pop item with dragging it. When an item is pop from the queue the next item appear.
The cell comprising the individual items of the queue are UIView objects; UIQueueView uses this cell to draw the visible items of the queue.

## Installation
* Download UIQueueView source files.
* Add the downloaded source files to your project.

## Usage

Go to the storyboard and drag a UIView. In the Identity inspector, set its Class to UIQueueView. That is the essential step for hooking up a scene from the storyboard with the UIQueueView. Don’t forget this or your UIQueueView won’t be used!

In the Identity inspector, you can define two property:
* numberOfItem, The number of items in queue view.
* itemIdentifier, The identifier for the cell. This parameter must not be nil and must not be an empty string.

### Managing the Delegate and the Data Source

#### Datasource Methods
**queueView:cellForItemAtIndex:** 
Asks the data source for a cell to insert in a particular location of the queue view.

**numberOfItemInQueueView:**
Asks the data source to return the number of items in the queue view.

**movingPositionsForPopItemInQueueView:**
Asks the data source to return the positions which allow users to pop an item.

#### Delegate Methods
**queueView:didMovingItemAtIndex:toPosition:withAngle:**
Tells the delegate that the queue view moving an item.

**queueView:didFinishMovingItemAtIndex:toPosition:withAngle:**
Tells the delegate that the queue view has moving an item.

### Creating Cell
* Create a xib file
* In the UIQueueView's Identity inspector set the property itemIdentifier withe the name of the created xib file

## Visual Exemple
Soon...
