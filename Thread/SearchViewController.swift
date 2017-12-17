//
//  SearchViewController.swift
//  Thread
//
//  Created by Developer on 3/8/17.
//  Copyright © 2017 JwitApps. All rights reserved.
//

import GameplayKit
import UIKit

import FirebaseDatabase

class Bubble: GKEntity, GKAgentDelegate {
    
    let visual: BubbleView
    
    let intelligence: GKAgent2D
    
    init(visual: BubbleView) {
        self.visual = visual
        self.intelligence = GKAgent2D()
        
        super.init()
        
        self.intelligence.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateBehavior(bubbles: [GKAgent2D]) {
        let cluster = GKGoal(toCohereWith: bubbles, maxDistance: 99999999999, maxAngle: 9999999999)
        let spacing = GKGoal(toSeparateFrom: bubbles, maxDistance: 80, maxAngle: 0)
        
        intelligence.behavior = GKBehavior(goals: [cluster, spacing], andWeights: [1, 5])
    }
    
    func agentWillUpdate(_ agent: GKAgent) {
    
//        intelligence.position = vector_float2(Float(visual.center.x), Float(visual.center.y))
    }
    
    func agentDidUpdate(_ agent: GKAgent) {
        guard !intelligence.position.x.isNaN, !intelligence.position.y.isNaN else { return }
        visual.center = CGPoint(x: CGFloat(intelligence.position.x),
                                y: CGFloat(intelligence.position.y))
    }
}

class BubbleView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SearchViewController: UIViewController {

    @IBOutlet weak var searchField: UITextField!
    
    var searchTags: Set<String> {
        return (searchField.text ?? "").components(separatedBy: " ").filter {
            $0.characters.count > 0 && $0 != " "
        }.set
    }
    
    var fetchedRelationships: [String : Set<String>] = [:]
    
    var allTags: Set<String> {
        return fetchedRelationships.reduce(Set<String>()) { $0.union($1.value) }
    }
    
    var commonTags: Set<String> {
        return fetchedRelationships.filter({
            return self.searchTags.contains($0.key)
        }).reduce(self.allTags ) {
            $0.intersection($1.value)
        }
    }
    
    let aiSystem = GKComponentSystem(componentClass: GKAgent2D.self)
    var aiTimer: Timer?
    var lastTime: TimeInterval = 0
    
    var bubbles: [Bubble] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchField.delegate = self
        
        searchField.addTarget(self, action: #selector(SearchViewController.searchTextChanged(sender:)), for: .editingChanged)
        
        lastTime = Date().timeIntervalSince1970
        aiTimer = Timer.scheduledTimer(withTimeInterval: 1/60.0, repeats: true) { _ in
            self.aiSystem.update(deltaTime: Date().timeIntervalSince1970-self.lastTime)
            self.lastTime = Date().timeIntervalSince1970
        }
    }
    
    func searchTextChanged(sender: Any) {
        let tagsRef = FIRDatabase.database().reference().child("tag")
    
        let newTags = searchTags.filter {
            fetchedRelationships[$0] == nil
        }
        
        for tag in newTags {
            tagsRef.child(tag).observeSingleEvent(of: .value, with: { snapshot in
                self.fetchedRelationships[tag] = (snapshot.children.allObjects as! [FIRDataSnapshot]).map({$0.key}).set
            
                print(self.commonTags)
                
                for tag in snapshot.children.allObjects {
                    let bubbleView = BubbleView(frame: CGRect(origin: self.view.center, size: CGSize(width: 10, height: 10)))
                    
                    self.bubbles.append(Bubble(visual: bubbleView))
                    
                    self.view.addSubview(bubbleView)
                }
                
                for bubble in self.bubbles {
                    self.aiSystem.addComponent(bubble.intelligence)
                    
                    bubble.updateBehavior(bubbles: self.bubbles.map{$0.intelligence})
                }
            })
        }
        

        
        
    }

}

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
