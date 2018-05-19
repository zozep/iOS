//
//  ViewController.swift
//  NamesToFaces
//
//  Created by Joseph Park on 5/16/18.
//  Copyright © 2018 Joseph Park. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var people = [Person]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        
        let defaults = UserDefaults.standard
        
        //we use the object(forKey:) method to pull out an optional Data, using if let and as? to unwrap it.
        //We then give that to an instance of JSONDecoder to convert it back to an object graph – i.e., our array of Person objects.
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            
            let jsonDecoder = JSONDecoder()
            
            //its first parameter is [Person].self, which is Swift’s way of saying “attempt to create an array of Person objects. This is why we don’t need a typecast when assigning to people – that method will automatically return [People], or if the conversion fails then the catch block will be executed instead.
            do {
                people = try jsonDecoder.decode([Person].self, from: savedPeople)
            } catch {
                print("failed to load people")
            }
        }
        

    }
    // MARK: - Custom Fx
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(people) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "people")
        } else {
            print("Failed to save people")
        }
        
    }
    
    
    @objc func addNewPerson() {
        let picker = UIImagePickerController()
        
        //allows the user to crop the picture they select
        picker.allowsEditing = true
        
        //set self as the delegate = need to conform to UIImagePickerControllerDelegate & UINavigationControllerDelegate protocols
        picker.delegate = self
        present(picker, animated: true)
    }
    
    
    // MARK: - CollectionView fx
    //This must return an integer, and tells the collection view how many items you want to show in its grid
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    //This must return an object of type UICollectionViewCell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as! PersonCell
        let person = people[indexPath.item]
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7

        return cell
    }

    // MARK: - ImagePicker fx
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //guard to pull out and typecast the image from the image picker, if that fails we want to exit the method immediately
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            return
        }
        
        //create an UUID object, and use its uuidString property to extract the unique identifier as a string data type
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)

        //converts a UIImage to a Data object
        //Data = data type that can hold any type of binary type – image data, zip file data, movie data, and so on
        if let jpegData = UIImageJPEGRepresentation(image, 80) {
            try? jpegData.write(to: imagePath)
        }
        
        //stores image name in the Person object and gives them a default name of "Unknown", before reloading the collection view.
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        

        collectionView?.reloadData()
        dismiss(animated: true)
        save()
    }
    
    //All apps that are installed have a directory called Documents where you can save private information for the app
    //it's not obvious how to find that directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
    
    // MARK: - CollectionView fx
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        
        let ac = UIAlertController(title: "Rename Person", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
            ac.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self, ac] _ in
                let newName = ac.textFields![0]
                person.name = newName.text!
                
                //self is required because we are inside a closure
                self.collectionView?.reloadData()
                self.save()

        })
            present(ac, animated: true)
    }
    
    
}
