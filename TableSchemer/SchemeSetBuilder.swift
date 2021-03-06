//
//  SchemeSetBuilder.swift
//  TableSchemer
//
//  Created by James Richard on 6/13/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

/** This class facilitates building the contents of a `SchemeSet`.

    An instance of this object is passed into the build handler from `TableSchemeBuilder.buildSchemeSet(handler:)`.
    It's used to set a section title and to add schemes to the scheme set.
 */
public final class SchemeSetBuilder {
    /** This will be used as the SchemeSet's header text. If left nil, the SchemeSet will not have a title. */
    public var headerText: String?
    
    /** This will be used as the SchemeSet's footer text. If left nil, it will not have a footer label */
    public var footerText: String?
    
    /** These are the Scheme objects that the SchemeSet will be instantiated with. */
    public var schemes: [Scheme] {
        return attributedSchemes.map { $0.scheme }
    }

    var attributedSchemes = [AttributedScheme]()
    
    /// This is used to identify if the scheme is initially hidden or not
    public var hidden = false
    
    /** Build a scheme within the closure.

        This method will instantiate a `Scheme` object, and then pass it into handler. The type of Scheme object
        that is instantiated will be inferred from the type passed into the handler.

        The created `Scheme` object will be validated before being added to the list of schemes to be created.

        The created `Scheme` object will be returned if you need a reference to it, but it will be added
        to the `TableScheme` automatically.

        - parameter     handler:    The closure to configure the scheme.
        - returns:                  The created Scheme instance.
     */
    public func buildScheme<BuilderType: SchemeBuilder>(@noescape handler: (builder: BuilderType, inout hidden: Bool) -> Void) -> BuilderType.SchemeType {
        let builder = BuilderType()
        var hidden = false
        handler(builder: builder, hidden: &hidden)

        let scheme = try! builder.createScheme()
        attributedSchemes.append(AttributedScheme(scheme: scheme, hidden: hidden))
        return scheme
    }

    public func buildScheme<BuilderType: SchemeBuilder>(@noescape handler: (builder: BuilderType) -> Void) -> BuilderType.SchemeType {
        let builder = BuilderType()
        handler(builder: builder)

        let scheme = try! builder.createScheme()
        attributedSchemes.append(AttributedScheme(scheme: scheme, hidden: false))
        return scheme
    }
    
    /** Create the `SchemeSet` with the currently added `Scheme`s. This method should not be called except from `TableSchemeBuilder` */
    internal func createSchemeSet() -> AttributedSchemeSet {
        return AttributedSchemeSet(schemeSet: SchemeSet(attributedSchemes: attributedSchemes, headerText: headerText, footerText: footerText), hidden: hidden)
    }
}