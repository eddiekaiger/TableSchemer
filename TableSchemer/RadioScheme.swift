//
//  RadioScheme.swift
//  TableSchemer
//
//  Created by James Richard on 6/13/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

/** This class is used with a `TableScheme` to display a radio group of cells.

    Use this scheme when you want to have a set of cells that represent
    a single selection, similar to a radio group would in HTML.

    In order for this scheme to handle changing selection be sure that your
    table view delegate calls `TableScheme.handleSelectionInTableView(tableView:forIndexPath:)`.

    It's recommended that you don't create these directly, and let the
    `SchemeSetBuilder.buildScheme(handler:)` method generate them
    for you.
 */
public class RadioScheme<CellType: UITableViewCell>: Scheme {
    
    public typealias ConfigurationHandler = (cell: CellType, index: Int) -> Void
    public typealias SelectionHandler = (cell: CellType, scheme: RadioScheme, index: Int) -> Void
    
    /** The currently selected index. */
    public var selectedIndex = 0
    
    /** The reuse identifiers that each cell will use. */
    public var expandedCellTypes: [UITableViewCell.Type]
    
    /** The heights that the cells should have if asked. */
    public var heights: [RowHeight]?
    
    /** The closure called for configuring the cell the scheme is representing. */
    public var configurationHandler: ConfigurationHandler
    
    /** The closure called when the cell is selected.
     *
     *  NOTE: This is only called if the TableScheme is asked to handle selection
     *  by the table view delegate.
    */
    public var selectionHandler: SelectionHandler?

    public init(expandedCellTypes: [UITableViewCell.Type], configurationHandler: ConfigurationHandler) {
        self.expandedCellTypes = expandedCellTypes
        self.configurationHandler = configurationHandler
    }
    
    // MARK: Property Overrides
    public var numberOfCells: Int {
        return reusePairs.count
    }
    
    // MARK: Public Instance Methods
    
    public func configureCell(cell: UITableViewCell, withRelativeIndex relativeIndex: Int)  {
        configurationHandler(cell: cell as! CellType, index: relativeIndex)
        
        if selectedIndex == relativeIndex {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
    }
    
    public func selectCell(cell: UITableViewCell, inTableView tableView: UITableView, inSection section: Int, havingRowsBeforeScheme rowsBeforeScheme: Int, withRelativeIndex relativeIndex: Int) {
        if let sh = selectionHandler {
            sh(cell: cell as! CellType, scheme: self, index: relativeIndex)
        }
        
        let oldSelectedIndex = selectedIndex
        
        if relativeIndex == oldSelectedIndex {
            return
        }
        
        selectedIndex = relativeIndex
        
        if let previouslySelectedCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: rowsBeforeScheme + oldSelectedIndex, inSection: section)) {
            previouslySelectedCell.accessoryType = .None
        }
        
        cell.accessoryType = .Checkmark
    }
    
    public func reuseIdentifierForRelativeIndex(relativeIndex: Int) -> String {
        return String(expandedCellTypes[relativeIndex])
    }
    
    public func heightForRelativeIndex(relativeIndex: Int) -> RowHeight {
        var height = RowHeight.UseTable
        
        if let rowHeights = heights where rowHeights.count > relativeIndex {
            height = rowHeights[relativeIndex]
        }
        
        return height
    }

}

extension RadioScheme: InferrableReuseIdentifierScheme {

    public var reusePairs: [(identifier: String, cellType: UITableViewCell.Type)] {
        return expandedCellTypes.map { (identifier: String($0), cellType: $0) }
    }

}
